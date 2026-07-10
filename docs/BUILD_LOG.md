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
