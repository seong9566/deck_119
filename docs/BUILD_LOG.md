# 119덱 빌드 로그 (정직 보고)

> BUILD_PLAN.md 순서대로 진행하며 결정·스킵·미완·이슈를 그대로 기록한다.

## T1 — 의존성 + Isar 부트스트랩 ✅

- 허용목록대로 `isar 3.1.0+1`·`isar_flutter_libs`·`path_provider 2.1.6`·(dev)`build_runner`·`isar_generator` 추가.
- `WrongEntry·AttemptRecord·SessionState·AppSettings` 컬렉션 스키마 정의(§2). `IsarService.open()`이 `path_provider` 문서 디렉터리에 1회 open, `main()`에서 초기화 후 `isarProvider`를 `ProviderScope.override`로 주입.
- 생성 코드(`*.g.dart`)에서 `experimental_member_use` 경고가 다수 발생 → `analysis_options.yaml`에서 `**/*.g.dart` analyzer 제외로 해소(생성 코드는 표준적으로 분석 제외).
- 검증: `flutter pub get` OK · `build_runner build` OK(12 outputs) · `flutter analyze` 0 · 기존 부팅 스모크 테스트 통과.

## T9 — 디자인 시스템 파운데이션 ✅

- `shared/theme`: `AppColors`(ThemeExtension, 라이트/다크 전 토큰)·`AppText`·`AppSpacing`/`AppRadius`·`AppTheme`. `shared/widgets`: §5 컴포넌트 전부(AppScaffold·QuestionCard·TypeBadge·ChoiceTile·AnswerBanner·ExplanationCard·PrimaryButton/SecondaryButton·ProgressHeader·ScoreView·ModeTile·EmptyState·ThemeRadioGroup) + 배럴.
- 홈·풀이 화면을 공용 컴포넌트로 재구성. 인라인 `_ChoiceTile`을 공용 `ChoiceTile`로 승격. 화면 파일에서 색/간격 하드코딩 제거.
- 라이트/다크 양쪽 렌더 위젯 테스트 추가(`test/shared/design_system_test.dart`).
- 검증: `flutter analyze` 0 · 테스트 통과.

## T2 — 오답·진척 Isar 영속화 ✅ (설계 판단 1건)

- `IsarProgressDataSource`(WrongEntry put/delete·AttemptRecord append) 신설, `ProgressRepositoryImpl`을 Isar 구현으로 교체, 인메모리 `LocalProgressDataSource` 삭제(내 변경으로 orphan). DI를 `isarProvider` 기반으로 교체.
- **설계 판단**: BUILD_PLAN §2는 "ProgressRepository 인터페이스 시그니처를 바꾸지 말 것(Presentation 영향 0)"을 명시. 그러나 §2 스키마의 `AttemptRecord.subjectId/selectedIndex/mode`, `WrongEntry.subjectId`는 `recordAttempt(questionId, {correct})` 경계로 전달되지 않는다. 두 지시가 충돌하여 **인터페이스 시그니처 유지(명시적 하드 지시)를 우선**하고, 경계에서 못 받는 필드는 **nullable로 두어 null 저장**(데이터 조작 대신 정직). 해당 필드는 MVP Must(오답 재풀이=`questionId`만 필요, 통계는 PRD Won't/Could)에서 소비되지 않으므로 기능 영향 없음.
- **테스트 환경 이슈**: `flutter test`의 `TestWidgetsFlutterBinding`이 HTTP를 차단(400)하여 `Isar.initializeIsarCore(download:true)`가 실패. IsarCore 네이티브(`libisar_macos.dylib`, 유니버설)를 `build/isar/libisar.dylib`(gitignore)로 사전 다운로드하고, `test/support/isar_test_core.dart`가 로컬 로드하도록 처리. 신규 체크아웃/CI에선 이 바이너리를 먼저 받아야 Isar 테스트가 돈다.
- 검증: `flutter analyze` 0 · Isar 유닛 테스트 4개(저장→재조회·정답 즉시 제거·unique 중복 방지·Repository 경유) 통과 · 전체 테스트 통과.

## T3 — 시험 모드 일괄채점 ✅

- `QuizState`를 문항별 선택(`answers`) 기반으로 재구성. `correctCount`·`wrongIndexes`는 파생. normal 계열은 선택 즉시 채점(`revealed`), exam은 채점을 숨기고 재선택 허용·`다음`으로만 전진·마지막에 `제출`.
- `QuizViewModel.submit()`: 전 문항 일괄 채점·기록(미응답은 `-1`→오답 처리). 결과 화면에 **오답 리뷰**(문항·내 답/정답·해설) 추가(normal 결과에도 공통 적용). 오답 리뷰 카드는 토큰으로 구현, T7에서 공용 컴포넌트로 마감 예정.
- 검증: `flutter analyze` 0 · 시험 플로우 위젯 테스트 2개(응답→제출→점수·오답 리뷰, 미응답 오답 채점) 통과.

## T4 — 이어풀기 세션 저장복원 ✅

- 신규 `SessionRepository` 포트 + `IsarSessionDataSource`/`SessionRepositoryImpl`(key=`"$subjectId:normal"`, upsert). UseCase 3개(GetResumeInfo·SaveSessionPosition·ClearSession) + DI.
- `QuizArgs`에 `resume` 추가(family 키). normal 모드: build에서 `resume`면 마지막 위치 복원, next마다 저장, finish 시 삭제. exam/random/review는 세션 미사용.
- 홈: `resumeInfoProvider`(과목별)로 세션 있으면 상단 강조 이어풀기 타일(`정규 · N/총`) 노출, 풀이에서 돌아오면 invalidate로 갱신.
- **결정**: "전체 풀이"(resume=false)는 index 0부터 새로 시작(첫 next에서 세션 덮어씀), "이어풀기"(resume=true)만 마지막 위치부터. 두 진입점을 명확히 분리.
- 홈 스모크 테스트를 Isar 비의존(fake Session/Progress 주입)으로 보강.
- 검증: `flutter analyze` 0 · Isar 세션 테스트 3개(저장→복원·삭제·과목분리) + 이어풀기 위젯 테스트 4개 통과.

## T5 — 다크모드 설정 영속 ✅

- domain은 Flutter-free 유지를 위해 도메인 enum `AppThemeMode`를 두고 presentation에서 Flutter `ThemeMode`로 매핑(`theme_mode_mapper.dart`). `SettingsRepository` 포트 + `IsarSettingsDataSource`/`SettingsRepositoryImpl`(AppSettings 단일 레코드 id=0). UseCase Get/SetThemeMode + DI.
- `SettingsController`(AsyncNotifier)가 저장값 로드·변경 즉시 반영·영속. `Deck119App`을 ConsumerWidget으로 바꿔 `MaterialApp.themeMode` 바인딩. `/settings` 화면(ThemeRadioGroup 라디오 + 앱 정보). 홈 우상단 설정 아이콘.
- 홈 스모크 테스트에 fake Settings 주입, 앱 레벨 테스트는 fake Question 주입(로딩 스피너로 인한 pumpAndSettle 타임아웃 회피).
- 검증: `flutter analyze` 0 · Isar 설정 테스트 3개(기본 system·재오픈 유지·단일 레코드) + 설정 위젯 테스트 3개(선택→저장·저장값 반영·즉시 반영) 통과.

## T6 — 라우팅 정리(go_router) ✅

- `go_router` 추가(허용목록). `createRouter()`로 `/`·`/quiz`(normal·random·review, mode 쿼리)·`/exam`·`/settings` 라우트 구성. subjectId·mode·resume는 쿼리 파라미터로 전달(`Routes.quizLink/examLink`).
- `routerProvider`(ProviderScope 단위 1개 = 테스트 격리). `Deck119App`을 `MaterialApp.router`로 전환. 홈 설정 아이콘·모드 타일은 `context.push(link)`, 결과 "홈으로"는 `context.pop()`.
- Navigator.push/MaterialPageRoute 제거(홈).
- 검증: `flutter analyze` 0 · 라우팅 위젯 테스트 3개(설정·풀이·시험 진입) 추가, 기존 테스트 전부 유지(총 25).

## T7 — 결과 오답 리뷰 UI 마감 + 표시명 ✅

- 결과의 인라인 오답 리뷰 카드를 공용 컴포넌트 `ReviewCard`(shared/widgets)로 승격(문항·내 답 ✕·정답 ✓·해설). quiz_page는 이를 조합만 하도록 정리(orphan 위젯 제거).
- 표시명 "119덱": Android `android:label`, iOS `CFBundleDisplayName` 설정.
- **앱 아이콘**: 범위 외 — 기본 Flutter 아이콘 유지(BUILD_PLAN §4 T7 명시). 교체하지 않음.
- 검증: `flutter analyze` 0 · ReviewCard를 디자인 시스템 렌더 테스트에 추가, 시험 결과 오답 리뷰 내용(내 답/정답 텍스트) 검증 강화 · 전체 테스트 통과(25).

## T8 — 최종 검증 + 완료 보고 ✅ (APK 빌드 스모크는 환경 이슈로 미완)

### 완료
- **`flutter analyze` = 이슈 0.**
- **`flutter test` = 25개 전부 통과.** (Isar 유닛 10 + 위젯/플로우 13 + 디자인시스템 2)
  - 데이터: 오답·진척(4), 세션(3), 설정(3)
  - 화면/플로우: 홈 스모크(1), 시험(2), 이어풀기(4), 설정(3), 라우팅(3)
  - 디자인 시스템 라이트/다크 렌더(2)
- MVP Must 전부 구현: 4모드 진입·즉시채점/해설·오답 즉시제거·오답 재풀이·**Isar 영속화**(오답/진척/세션/설정)·**시험 일괄채점**·**결과 오답 리뷰**·**이어풀기**·**다크모드 토글+영속**·**go_router 5화면**·디자인 시스템 토큰/공용 컴포넌트·표시명 119덱.

### 미완/스킵 (정직 보고)
- **`flutter build apk --debug` 실패** — 앱 코드가 아니라 의존성/툴체인 버전 불일치.
  - 원인: 환경 AGP `com.android.application 9.0.1`(최신)인데, 허용목록으로 고정된 `isar_flutter_libs 3.1.0+1`은 AGP 7.3.1 기준이라 Gradle `namespace` 미선언(`Namespace not specified`) + `compileSdkVersion 30`. AGP 8+에서 요구되는 namespace가 없어 구성 단계에서 실패.
  - 조치 안 한 이유: 의존성 변경은 허용목록/승인 필요(§0·가드레일)라 isar 업그레이드/교체 불가. namespace를 Gradle 훅으로 강제 주입해도 오래된 compileSdk 등 후속 AGP 9 비호환이 연쇄될 위험이 커 "가능하면" 범위인 빌드 스모크에 무리한 해킹을 넣지 않음.
  - 권장 해소: (승인 시) `isar_flutter_libs`를 namespace를 선언한 유지보수 포크/상위 버전으로 교체하거나, Android AGP를 8.x 계열로 낮춰 정합. 또는 루트 `android/build.gradle.kts`에 isar 모듈 한정 namespace 주입 훅 추가(별도 승인/검증 필요).
- **iOS 빌드**: 이 비대화형 환경에 시뮬레이터/코드사인 없음 → 미시도.
- **앱 아이콘**: 범위 외(T7) — 기본 유지.
- **Isar 테스트 네이티브 코어**: `build/isar/libisar.dylib` 사전 다운로드 필요(T2 참조). 신규 체크아웃/CI에서 이 바이너리 없으면 Isar 유닛 테스트가 코어 로드 실패.

### 결론
코드 품질 게이트(analyze 0 · 테스트 25 통과)와 MVP Must 기능은 완주. Android 릴리스 빌드는 의존성 버전 정합(승인 필요) 후 가능.

---

# 페이즈 2 — 디자인 반영 (T10~T16)

## T10 — 토큰 목업값 반영 + Pretendard 번들 ✅

- `AppColors` 라이트/다크를 DESIGN_HANDOFF §1.1/§1.2 확정값으로 교체하고 신규 토큰(brandInk·brandTint·outlineStrong·textTertiary·correctInk·wrongInk·sel·selTint·shadow) 추가. 기존 위젯이 쓰던 필드명(surfaceVariant=surfaceAlt, onCorrect=correctTint, onWrong=wrongTint)은 하위호환 유지 → T10에선 위젯 코드 변경 0.
- `AppText`를 Pretendard 스케일(§1.3)로 교체(score 56/w800 등) + scoreUnit·logo·subjectName·oxGlyph·tab 역할 신설. `ThemeData.fontFamily='Pretendard'` 전역 상속.
- spacing xl 20·xxl 24·huge 32(화면 좌우 20), radius tile 14·card 16·ox 20·iconBadge 28·badge 8(§1.4).
- pubspec에 Pretendard 4 weight(400/500/600/700) 등록(승인 예외). otf 파일은 assets/fonts/에 기존 존재. 목업은 900까지 쓰나 번들 파일은 4개뿐 → 800/900 요청은 700로 근사(Flutter 최근접 매칭).
- 검증: `flutter pub get` OK · `flutter analyze` 0 · `flutter test` 전부 통과(색값 하드 검증 테스트 없어 기대값 갱신 불필요).
- **인프라 메모(주의)**: PM `task.sh`가 ID만으로 매칭 → toss-자동매매 프로젝트에도 T10이 있어 `wip T10 --force`가 toss T10(done)을 건드림. 즉시 toss를 done으로 원복하고, 소방 T10은 태스크 파일을 직접 편집해 상태 전환. post-commit 훅의 `done T10`도 동일 모호성으로 소방을 자동 done 못 함 → 수동 done 처리. 이후 T11~T16도 태스크 파일 직접 편집으로 상태 관리 예정.
