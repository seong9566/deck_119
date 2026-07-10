# 119덱 MVP 빌드 계획 (자율 빌드용, 자체완결)

> 이 문서 하나로 MVP Must 전체를 완주할 수 있게 작성한다. 결정은 확정됐고(아래), 각 태스크는 **검증 기준(DoD)**을 가진다. 순서대로 진행하고, 각 태스크 끝에 `flutter analyze`(이슈 0) + 관련 테스트 통과를 확인한다.
> 상위 맥락(왜): vault `wiki/projects/소방-기출앱/` (PRD·ADR-0001·architecture). 이 문서와 충돌하면 이 문서를 우선(더 구체적).

## 0. 확정된 결정 (2026-07-11, 변경 금지)

- **범위** = MVP Must 전체 (**Isar 영속화 포함**). "로그인 없이 로컬 저장"을 실제로 충족한다.
- **시험 모드** = 전체 25문항, **제한시간 없음**. 풀이 중 즉시 채점을 숨기고, 종료 시 **일괄 채점 + 점수 + 오답 리뷰**.
- **다크모드** = **수동 토글(light/dark/system) + 설정 영속**. `MaterialApp.themeMode`에 연결.
- **오답 제거 규칙** = 정답 시 **즉시 제거**(PRD 오픈이슈 1 확정).
- **이어풀기** = normal 모드 한정, 과목별 마지막 위치 저장·복원.
- **의존성 허용목록**(이 외 추가 금지): `isar`, `isar_flutter_libs`, `path_provider`, `go_router`, (dev) `build_runner`, `isar_generator`.

## 1. 현재 상태 (스캐폴드 완료분)

MVVM + 클린 아키텍처 골격이 이미 있고 `flutter analyze` 0·스모크 테스트 통과 상태다.

```
lib/
├── main.dart · di.dart
├── domain/      entities(Question·Subject·QuizMode) · repositories(QuestionRepository·ProgressRepository) · usecases(GetQuestionSet·SubmitAnswer)
├── data/        datasources(ContentDataSource=번들JSON · LocalProgressDataSource=인메모리) · models(QuestionDto) · repositories(impl 2)
└── presentation/ home(view+viewmodel) · quiz(view+viewmodel+state) · shared/theme
assets/content/fire-law.json   # 25문항(검수 완료 — 정답·해설 수정 금지)
```

동작: 4모드 진입 · 한문제씩 · 즉시채점 · 해설 · 오답 인메모리 누적 · 오답 재풀이 · 점수 · 다크 테마(토글 없음).

## 2. 데이터 영속화 스펙 (Isar)

`data/datasources/local/` 아래 Isar 스키마. 모든 쓰기 상태는 Isar에, 콘텐츠는 계속 번들 JSON(읽기 전용).

### 컬렉션
- **WrongEntry** — 오답 세트. `questionId`(unique index), `subjectId`, `addedAtMs`(int). 오답 발생 시 put, 정답 시 delete(즉시 제거 규칙).
- **AttemptRecord** — 시도 이력(진척). auto id, `questionId`, `subjectId`, `selectedIndex`, `isCorrect`, `mode`(문자열), `timestampMs`. (통계는 Could지만 기록은 남긴다.)
- **SessionState** — 이어풀기. `key`(unique, `"$subjectId:normal"`), `subjectId`, `lastIndex`, `updatedAtMs`. next()마다 upsert, finish 시 delete.
- **AppSettings** — 단일 레코드(id 고정). `themeMode`(`"light"|"dark"|"system"`, 기본 `"system"`).

### 규칙
- Isar 인스턴스는 앱 시작 시 1회 open(`path_provider`로 디렉터리). `main()`에서 초기화 후 `ProviderScope` override로 주입하거나 async provider로.
- `ProgressRepository` 인터페이스는 유지, `ProgressRepositoryImpl`을 **Isar 구현으로 교체**(인메모리 DataSource 제거 또는 대체). 인터페이스 시그니처는 바꾸지 말 것(Presentation 영향 0).
- `SettingsRepository`(신규 port) + Isar 구현 추가 → 다크모드.
- `SessionRepository`(신규 port) 또는 ProgressRepository에 세션 메서드 추가 → 이어풀기.

## 3. 화면 정의서

| 화면 | 경로 | 내용 | 상태(state) |
|---|---|---|---|
| 홈 | `/` | 과목 카드 + 모드 버튼(전체/랜덤/오답/시험) + **이어풀기**(세션 있으면) + 우상단 **설정** 아이콘 | loading / error / data |
| 풀이 | `/quiz` | normal·random·review 공용. 한문제씩, 선택 즉시 채점·색상·해설, 다음, 진행바 | loading / empty(오답없음) / 문항 / 종료→결과 |
| 시험 | `/exam` | 전체 25문, **즉시채점 숨김**, 다음으로만 진행, 마지막에 제출 | 문항 / 제출→결과 |
| 결과 | 결과 뷰 | 점수 n/총 + **오답 리뷰**(문항별 내 답/정답/해설) + 다시풀기·홈 | — |
| 설정 | `/settings` | 테마 라디오(시스템/라이트/다크), 앱 정보 | 설정 로드/저장 |

- 네비게이션: **go_router** 도입(화면이 5개로 늘어 Navigator.push보다 명확). 라우트 파라미터로 subjectId·mode 전달.
- 빈/에러 상태 반드시 처리(오답 없음, 에셋 로드 실패).
- 카피는 한국어. 표시명 "119덱".

### 3.5 디자인 시스템 (필수)

- **모든 화면·위젯은 `docs/UI_DESIGN_SYSTEM.md`의 토큰·공용 컴포넌트만 사용**한다. 방향 = 차분한 뉴트럴 + 소방 레드 액센트.
- 토큰(색·타이포·간격)은 `lib/presentation/shared/theme/`, 공용 컴포넌트는 `lib/presentation/shared/widgets/`.
- 화면 파일에서 색/간격 **하드코딩 금지**(`Color(0x..)`·매직 패딩). 이 파운데이션은 **T9**에서 먼저 만들고(§4), 이후 UI 태스크가 재사용한다.

## 4. 태스크 (실행 순서 · 각 DoD 충족)

> 각 태스크: 구현 → `flutter analyze` 이슈 0 → 관련 위젯/유닛 테스트 작성·통과. 실패는 정직히 기록(BUILD_LOG.md).
> **실행 순서 = T1 → T9 → T2 → T3 → T4 → T5 → T6 → T7 → T8.** (T9 디자인 시스템은 데이터/화면 태스크보다 먼저 세워 이후 모든 UI가 재사용.)

- **T9. 디자인 시스템 파운데이션 (T1 다음 실행)**
  - `docs/UI_DESIGN_SYSTEM.md`대로 `shared/theme/`(ColorScheme+AppColors ThemeExtension·타이포·spacing/radius) + `shared/widgets/`(§5 컴포넌트: AppScaffold·QuestionCard·ChoiceTile·AnswerBanner·ExplanationCard·PrimaryButton·ProgressHeader·ScoreView·ModeTile·EmptyState·ThemeRadioGroup) 구축. 기존 인라인 ChoiceTile(quiz_page)을 공용 컴포넌트로 승격.
  - DoD: 라이트/다크 양쪽 렌더 확인 · 하드코딩 색/간격 없음 · `flutter analyze` 0.
- **T1. 의존성 + Isar 부트스트랩**
  - 허용목록 추가, `path_provider`로 dir, Isar open, `main()` 초기화, DI 주입.
  - DoD: `flutter pub get` OK · `dart run build_runner build --delete-conflicting-outputs` OK · `flutter analyze` 0 · 앱 부팅 스모크 테스트 통과.
- **T2. 오답·진척 영속화**
  - WrongEntry·AttemptRecord 컬렉션, LocalProgress를 Isar 구현으로 교체, ProgressRepositoryImpl 연결.
  - DoD: 오답 저장→재조회 유닛 테스트 · "정답 시 즉시 제거" 테스트 · analyze 0. (재시작 유지: Isar 임시 인스턴스로 검증)
- **T3. 시험 모드**
  - QuizMode.exam 분기: 즉시채점 숨김, 마지막 문항 후 제출 버튼 → 일괄채점 → 결과. 결과에 **오답 리뷰**(내 답/정답/해설).
  - DoD: 시험 플로우 위젯 테스트(응답→제출→점수) · analyze 0.
- **T4. 이어풀기**
  - SessionState 저장(next마다)·복원, 홈에 "이어풀기(정규, N/총)" 진입점, finish 시 삭제.
  - DoD: 세션 저장→복원 테스트 · analyze 0.
- **T5. 다크모드 설정**
  - AppSettings·SettingsRepository, `/settings` 화면(라디오), MaterialApp `themeMode` 바인딩, 영속.
  - DoD: 토글→저장→재로드 반영 테스트 · analyze 0.
- **T6. 라우팅 정리(go_router)**
  - 위 화면들을 go_router 라우트로. 홈 설정 아이콘·결과 네비 정리.
  - DoD: 라우팅 후 기존 테스트 유지·analyze 0.
- **T7. 결과 오답 리뷰 UI 마감 + 표시명**
  - 결과 화면 오답 리뷰 완성. Android `android:label`·iOS `CFBundleDisplayName` = "119덱". (앱 아이콘 디자인은 범위 외 — 기본 유지, BUILD_LOG에 기록)
  - DoD: analyze 0 · 전체 테스트 통과.
- **T8. 최종 검증 + 완료 보고**
  - `flutter analyze`(0) · `flutter test`(전부 통과) · 가능하면 `flutter build apk --debug` 스모크.
  - `docs/BUILD_LOG.md`에 완료/미완/이슈를 정직히 정리(무엇을 못 했고 왜).

## 5. 검증 런북 (매 태스크·최종)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Isar 코드젠(스키마 바뀌면)
flutter analyze          # 이슈 0 목표
flutter test             # 전부 통과
# 최종만:
flutter build apk --debug   # (환경 되면) 빌드 스모크
```

## 6. 가드레일 (반드시 준수)

- **의존성**: §0 허용목록 내에서만. 그 외 필요하면 **추가하지 말고** 대안 구현하거나 스킵 후 BUILD_LOG에 기록.
- **콘텐츠 불변**: `assets/content/*.json`의 정답·해설·지문은 **수정 금지**(검수 완료값). 스키마 확장이 필요하면 매퍼에서 흡수.
- **디자인 시스템 준수**: 모든 화면은 `docs/UI_DESIGN_SYSTEM.md` 토큰·공용 컴포넌트만 사용. 화면별 색/간격 하드코딩 금지.
- **레이어 유지**: domain은 Flutter·Isar import 0. Presentation은 UseCase만 호출. 저장소 교체는 impl에서만.
- **범위 준수**: MVP Must만. 통계 대시보드·클라우드 동기화·검색·북마크 등 **만들지 말 것**(PRD Won't).
- **정직 보고**: 못 한 것·추측한 것·스킵한 것은 BUILD_LOG.md에 그대로. 오버클레임 금지.
- **커밋**(git 초기화돼 있을 때만): 태스크 단위 커밋, 메시지 한국어, 끝에 `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
