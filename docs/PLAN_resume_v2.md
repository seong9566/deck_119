# 계획서 — 풀이 이력 영속화 v2 (AI 문제함 이력 + 전 모드 이어풀기)

작성 2026-08-02 · 상태: **구현 완료** (결과·미검증 항목은 `docs/BUILD_LOG.md` §풀이 이력 영속화 v2 참조)

---

## 0. 문제와 원인 (코드 확인 완료)

두 증상은 하나의 뿌리다 — **AI 모드에는 풀이 상태를 저장하는 경로가 전혀 없다.**

| # | 증상 | 실제 원인 |
|---|---|---|
| 1 | 새로 발급하면 이전에 푼 문제가 다시 미풀이로 나온다 | `quiz_view_model.dart:56` `if (arg.mode != QuizMode.ai)` 가드로 AI 문항은 `SubmitAnswer`를 타지 않는다. 즉 **정답이 날아간 게 아니라 애초에 저장된 적이 없다.** 매 진입 시 `index: 0`, `answers` 전부 null. |
| 2 | 풀다가 나가면 처음부터 | `_saveSessionIfNormal()` — 세션 저장이 `QuizMode.normal` 전용. `Sessions.key`도 `"$categoryId:normal"` 하드코딩이라 다른 모드용 슬롯 자체가 없다. |

부수 함정: `home_page.dart:46` → `getAll()`이 `createdAtMs DESC`(최신순)라 새 문항이 목록 **맨 앞**에 붙는다. 인덱스 기반 저장은 생성할 때마다 전부 밀려 깨진다 → **questionId 기반 저장이 필수.**

추가 발견(같이 고침): `GetResumeInfo`가 `snap.lastIndex <= 0`이면 null을 반환한다. 1번 문항만 풀고 나가면 이어풀기 진입점이 아예 안 뜬다.

---

## 1. 확정된 결정 (인터뷰 결과)

| 항목 | 결정 |
|---|---|
| AI 풀이 기록 저장 위치 | **AI 전용 테이블 신설.** 통계·오답노트(`AttemptRecords`/`WrongEntries`)는 기출 문항만 — ADR-0002 의도 유지 |
| AI 재진입 | **진입 시 선택 다이얼로그** (이어풀기 / 처음부터 다시) |
| AI 이어풀기 동작 | **전체 목록 유지 + 첫 미풀이 문항으로 점프** (푼 문항은 답·해설 복원, 뒤로 넘겨 복습 가능) |
| AI 처음부터 다시 | **해당 과목 AI 풀이 기록 전체 초기화** (다이얼로그에 경고 문구) |
| AI 문항 정렬 | **오래된순**(생성 순서대로 뒤에 쌓임) — 현재 최신순에서 변경 |
| 이어풀기 적용 범위 | **전 모드** — normal · random · quick · review · exam |
| 시험 모드 | **포함** — 제출 전까지 임시저장, 제출 시 세션 삭제 |
| 오답 재풀이 세션 | **시작 시점 목록 고정** (풀이 중 오답노트가 변해도 세트 불변) |
| 홈 이어풀기 카드 | **최근 1개 + 모드 라벨**, 해당 모드로 정확히 진입 |
| 홈 AI 카드 | 이어풀기 카드에서는 **제외**. 기존 AI 문제함 카드에 `미풀이 N문항` 표시 |

---

## 2. 설계

### 2.1 DB 스키마 v4 → v5

**(a) `Sessions` 확장** — 모드별 세션 + 출제 목록 고정

```dart
class Sessions extends Table {
  TextColumn get key => text()();            // "$categoryId:$mode"  (기존 ":normal")
  TextColumn get subjectId => text()();
  TextColumn get mode => text().withDefault(const Constant('normal'))();  // 신규
  TextColumn get questionIds => text().withDefault(const Constant(''))(); // 신규, CSV
  IntColumn  get lastIndex => integer()();
  TextColumn get answers => text()();
  IntColumn  get updatedAtMs => integer()();
}
```

- `questionIds`: random·quick은 셔플, review는 시작 시점 오답 세트 — **출제 목록 자체를 저장해야** 복원된다. normal·exam은 결정적이라 비워둬도 되지만 일관성을 위해 동일하게 저장.
- 복원 시 `questionIds`가 비었으면(v4에서 올라온 기존 행) 저장소 순서를 그대로 쓴다 → 하위호환.

**(b) `AiAnswers` 신설** — AI 문항 풀이 기록의 유일한 원천

```dart
class AiAnswers extends Table {
  TextColumn get questionId => text()();      // PK — 합성 id "ai-<us>-<i>"
  TextColumn get subjectId => text()();
  IntColumn  get selectedIndex => integer()();
  BoolColumn get isCorrect => boolean()();
  IntColumn  get answeredAtMs => integer()();
  @override Set<Column> get primaryKey => {questionId};
}
```

**(c) 마이그레이션 (`schemaVersion = 5`)**

```dart
if (from < 5) {
  await m.addColumn(sessions, sessions.mode);
  await m.addColumn(sessions, sessions.questionIds);
  await m.createTable(aiAnswers);
  // 기존 행의 key는 이미 ":normal" 접미사 → mode 기본값 'normal'과 일치, 데이터 보존
}
```
기존 사용자의 진행 중 세션은 **삭제하지 않는다**(v4의 `DELETE FROM sessions`와 달리).

### 2.2 AI 모드 흐름

`Sessions`를 쓰지 않는다. `AiAnswers`가 곧 진행 상태다(문항 집합이 계속 늘어나므로 인덱스 세션은 부적합).

```
홈 [AI 문제함 · 미풀이 N문항] 탭
  ↓ getAll(subjectId)  ← 정렬 ASC 로 변경
  ↓ AiAnswers 조회 → 푼 문항 map
  ├ 미풀이 0                     → "모두 푸셨어요. 처음부터 다시 풀까요?" (초기화 / 취소)
  ├ 푼 문항 0                     → 다이얼로그 없이 바로 1번부터
  └ 일부만 풀었음                  → [이어풀기 (N/M) / 처음부터 다시]
        ├ 이어풀기   → answers 복원, index = 첫 미풀이 문항
        └ 처음부터   → AiAnswers 해당 subject 전체 삭제 후 index 0
  ↓ 풀이 중: select() 시마다 AiAnswers upsert  (통계·오답노트에는 기록 안 함 — 현행 유지)
```

### 2.3 일반 모드(normal·random·quick·review·exam) 이어풀기

`QuizViewModel`에서 모드 분기를 제거하고 일반화한다.

- **build**: `resume`이면 `Sessions[$categoryId:$mode]` 로드 → `questionIds`로 세트 복원 → `answers`·`lastIndex` 복원. 아니면 `GetQuestionSet` + 세션 신규 생성.
- **저장**: `select()` 즉시 저장(전 모드). `next()`로 미풀이 문항에 새로 진입할 때 위치 전진(현행 로직 유지).
- **exam**: 선택만 저장(채점은 `submit()` 시점 그대로). `submit()` 성공 시 세션 삭제.
- **finish**: 세션 삭제.

`GetResumeInfo`는 `(categoryId, mode)`를 받도록 확장하고, `lastIndex <= 0` 조건을 **"응답이 하나라도 있으면 노출"** 로 완화한다.

### 2.4 홈 · 세트 화면

- `RecentSession`에 `mode` 추가 → 카드에 `랜덤 · 12/25` 형태로 모드 라벨 표시, `Routes.quizLink(id, mode, resume: true)`로 진입.
- `set_mode_page.dart:67` `_ContinueTile`이 무조건 `QuizMode.normal`로 여는 버그 동반 수정.
- AI 문제함 카드: `watchCount`에 더해 미풀이 수를 함께 구독해 `미풀이 N문항` 표시.

---

## 3. 파일별 변경

| 파일 | 변경 |
|---|---|
| `data/datasources/local/app_database.dart` | Sessions 2컬럼 추가, AiAnswers 신설, v5 마이그레이션 |
| `…/drift_session_data_source.dart` | 키 `:$mode`, questionIds 직렬화, recent에 mode 노출 |
| `…/drift_ai_answer_data_source.dart` **(신규)** | upsert / 과목별 조회 / 과목별 삭제 |
| `…/drift_generated_data_source.dart` | 정렬 DESC → **ASC** |
| `domain/repositories/session_repository.dart` | 전 메서드에 `mode` 파라미터, `questionIds` 왕복 |
| `domain/repositories/ai_answer_repository.dart` **(신규)** | 포트 정의 |
| `data/repositories/session_repository_impl.dart`, `ai_answer_repository_impl.dart` **(신규)** | 구현 |
| `domain/entities/recent_session.dart`, `resume_info.dart` | `mode` 필드 추가 |
| `domain/usecases/get_resume_info.dart` | `(categoryId, mode)`, 노출 조건 완화 |
| `…/save_session_position.dart`, `clear_session.dart` | `mode`·`questionIds` 전달 |
| `domain/usecases/get_ai_quiz_set.dart` **(신규)** | 누적 문항 + AiAnswers 병합 → (questions, answers, firstUnsolvedIndex) |
| `domain/usecases/record_ai_answer.dart`, `reset_ai_answers.dart` **(신규)** | AI 기록 저장·초기화 |
| `presentation/quiz/viewmodel/quiz_view_model.dart` | 세션 일반화, AI 기록 경로 추가 |
| `presentation/home/view/home_page.dart` | AI 진입 다이얼로그, 미풀이 수 표시, 이어풀기 카드 모드 라우팅 |
| `presentation/home/viewmodel/home_view_model.dart` | 카드에 mode, AI 미풀이 수 provider |
| `presentation/home/view/set_mode_page.dart` | `_ContinueTile` 모드 라우팅 수정 |
| `lib/di.dart` | 신규 DS·Repo·UseCase 배선 |

의존성 추가 **없음**(BUILD_PLAN §0 허용목록 준수). `build_runner` 재생성 1회 필요.

---

## 4. 작업 순서와 검증 (DoD)

| 단계 | 내용 | 검증 |
|---|---|---|
| 1 | 스키마 v5 + 마이그레이션 + build_runner | `session_migration_test` 확장: v4 데이터가 v5에서 보존, AiAnswers 생성 확인 |
| 2 | DataSource·Repository·UseCase (AI 기록) | 신규 `drift_ai_answer_test`: upsert·조회·과목 초기화 |
| 3 | AI 문제함 흐름 (문제 1) | 신규 `ai_resume_flow_test`: 5문항 풀고 나감 → 5문항 추가 생성 → 재진입 시 앞 5문항 답 복원 + 6번으로 점프 |
| 4 | 세션 모드 일반화 (문제 2) | `resume_flow_test` 확장 + 신규 모드별 케이스: random 3문항 풀고 이탈 → 재진입 시 **같은 셔플 순서**로 4번부터 |
| 5 | 시험 모드 임시저장 | `exam_flow_test` 확장: 선택 후 이탈 → 재진입 복원 → 제출 시 세션 삭제 |
| 6 | 홈·세트 화면 배선 | `home_reactive_test` 확장: 카드 모드 라벨 + 해당 모드 진입, AI 미풀이 수 |
| 전체 | | `flutter analyze` 이슈 0 · `flutter test` 전체 통과 |

브랜치: `fix/ai-history-and-resume` (기존 T1~T8 태스크 범위 밖의 버그 수정이라 신규 T 번호 없이 진행 — 필요하시면 vault에 태스크로 등록)

---

## 5. 리스크

1. **기존 사용자 세션** — v5 마이그레이션은 `DELETE` 없이 컬럼만 추가한다. 기존 행은 `mode='normal'`, `questionIds=''`로 정상 복원.
2. **AI 문항 정렬 변경(DESC→ASC)** — 기존 사용자가 보던 순서가 뒤집힌다. 어차피 풀이 기록이 없던 상태라 실질 손실은 없다.
3. **`answers`/`questionIds` 길이 불일치** — 콘텐츠 갱신으로 문항이 사라진 경우. 복원 시 길이 방어 + id 매칭 실패분 스킵, 전부 실패면 세션 폐기 후 새로 시작.
4. **범위** — PRD Won't(검색·북마크·통계 대시보드·클라우드 동기화)는 건드리지 않는다.
