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

## T15 — 결과/설정/빈·에러 리스킨 ✅

- **결과**(`quiz_page.dart _ResultView`): AppScaffold → 풀스크린 Scaffold(상단 "채점 결과"+닫기✕ · 중앙 ScoreView · 오답 리뷰 헤더["오답 리뷰"+"N문항" pill] · ReviewCard 목록 · 하단 고정 홈으로/다시 풀기[3:1]). 만점 시 오답 대신 `_PerfectCard`(correctTint). ScoreView에 결과 태그(만점=correct"만점·완벽 ✓" / 그외=selTint"수고했어요 ↗") 반영.
- **설정**(`settings_page.dart`): 화면 제목 "설정" · 섹션 "테마"(ThemeRadioGroup) · 섹션 "앱 정보" 카드(버전 1.0.0 · **오픈소스 라이선스** → `showLicensePage` 실제 구현) · 푸터 "119덱 · 소방관계법규". §3-3대로 "문의하기" 없음. 기존 "앱 이름/설명" 정보타일은 목업 IA로 대체.
- **테마 라디오**(`theme_radio_group.dart`): 아이콘 라디오 → 라벨 좌·우측 커스텀 링(선택=brand 7px, 미선택=outlineStrong 2px), 행 min-height 56, 카드 clip.
- **에러/로딩/빈 상태**: 이미 T14 셸(`_QuizScaffold`)에 구현됨. 에러 카피는 §3-2대로 오프라인 번들에 맞게("문제를 불러오지 못했어요 / 다시 시도해 주세요", 원인=문항 데이터 열기 실패). 오답 빈 상태 "풀 오답이 없어요"(correctTint ✓).
- **테스트**: 결과 헤더 카피 변경("오답 리뷰 (1)" → "오답 리뷰" + "1문항")으로 `exam_flow_test.dart` 기대값만 갱신(§3-4, 로직 불변).
- **미포함(surgical)**: 작업 트리의 `ios/` 변경(Pods 참조·Main.storyboard 재포맷)은 Xcode/flutter 툴링 자동생성분으로 T15와 무관 → 커밋에서 제외.
- 검증: `flutter analyze` 0 · `flutter test` 26개 전부 통과.

## T16 — 최종 검증 + 완료 보고 (페이즈 2) ✅

### 검증 결과
- **`flutter analyze` = 이슈 0.**
- **`flutter test` = 26개 전부 통과.** (T8 시점 25 + 시험 결과 오답 리뷰 헤더 검증 1 추가)

### 목업 대비 반영 (T10~T15)
- **토큰/폰트(T10)**: §1.1/§1.2 라이트·다크 색, §1.3 Pretendard 타이포 스케일, §1.4 spacing/radius 전부 `shared/theme` 경유. 하드코딩 0.
- **공용 컴포넌트(T11)**: ChoiceTile(idle/sel/correct/wrong/dimmed + ✓✕ pop)·QuestionCard·ExplanationCard·ProgressHeader·Primary/SecondaryButton·ScoreView·ReviewCard·EmptyState·ModeTile.
- **IA(T12)**: ShellRoute + 하단 탭바 3탭(홈·과목·설정), 풀이/시험/결과 풀스크린, 닫기✕ 홈 복귀.
- **홈/과목(T13)**: 선택 과목 카드·이어풀기 타일·모드 2×2 그리드 / 과목 화면(실제 1과목).
- **풀이/시험(T14)**: 진행헤더·배지·stem·MC 세로/OX 대형 2버튼·채점 색전환·해설 배너·시험 채점숨김/제출.
- **결과/설정/빈·에러(T15)**: 결과 점수 태그·오답 리뷰 카드·만점 카드 / 설정 테마 라디오·앱 정보·오픈소스 라이선스 / 오답 빈 상태·오프라인 에러 카피.

### 의도적 미반영 (스코프 가드 §3 — 목업 데모 더미)
- **4과목·진행률(%)·done 카운트**: 목업의 소방학개론·행정법총론·소방전술 및 진행 수치는 데모 더미 → 하드코딩 안 함. 실재 과목 = 소방관계법규 1개만 렌더(§3-1).
- **네트워크 에러 카피**: 오프라인 번들 앱에 부적합 → "문항 데이터 열기 실패" 계열로 대체(§3-2).
- **문의하기**: MVP 범위 밖 → 미포함(§3-3). 오픈소스 라이선스는 `showLicensePage`로 실제 구현.
- **폰트 weight 800/900**: 번들 otf 4종(400/500/600/700)만 등록 → 최근접 700 매칭(T10 기록).

### 스크린샷
- 이 비대화형 환경에 시뮬레이터/디바이스 없음 → 라이트/다크 실기 스크린샷 미첨부. 라이트/다크 렌더는 `design_system_test`(두 테마) 및 각 플로우 위젯 테스트로 대체 검증.

### 결론
페이즈 2(비주얼 리스킨 + 탭바 IA) 완주. 기능/로직 회귀 없음(색값 변경으로 깨진 테스트는 기대값만 갱신). 코드 게이트: analyze 0 · test 26 통과.

## 후속(deferred) — 홈 대시보드 반응형 전환 (PR #4, 2026-07-20)

이어풀기·진척·오답을 drift `.watch()` StreamProvider로 전환(과목 탭 풀이 후 홈이 재시작 전까지 갱신 안 되던 버그 수정). Codex 재리뷰가 지적한 아래 2건은 **MVP 규모 대비 과하다고 판단해 후속으로 보류**(사용자 승인):

- **[P2a] normal 모드 응답당 전체 이력 재스캔** — `watchStats`가 답 1개당 `SELECT *`+Dart 집계를 전체 `attempt_records`에 재실행(홈이 StatefulShell로 마운트된 채라 구독 유지). 배치 픽스는 시험 제출 경로만 해결. 근본 해법 = SQL 집계(count/correct/distinct)+streak 재설계, 또는 증분 요약 테이블, 또는 홈 가시성 기반 구독. 단일 사용자·로컬 데이터 규모라 현시점 영향 미미.
- **[P2b] 자정 경과 시 연속학습일수 미갱신** — `_streak`는 `DateTime.now()` 의존인데 스트림은 테이블 쓰기 때만 방출. 앱을 자정 넘겨 켜둔 채 쓰기가 0이면 어제 값 유지(다음 답·재시작이면 정정). 저비용 해법 = 앱 lifecycle resume 시 `progressStatsProvider` 갱신.

원래 버그는 수정 + `home_reactive_test`로 E2E 검증 완료. 위 2건은 성능·시간의존 엣지로, 데이터가 커지거나 실사용 피드백이 있으면 착수.

## 할 일(TODO) — 플랫폼 번들 ID 통일 (2026-07-20)

**현재 상태(의도적 분리)**: Firebase App Distribution 배포를 위해 플랫폼별 번들 ID가 갈려 있음.
- Android: `com.seong.deck119` (Firebase Android 앱)
- iOS: `com.hyeonseong.fireDeck` (기존 fireDeck iOS 앱 재사용 — 이전에 이 번들로 배포한 이력이 있어 그대로 이어감. 팀 N264GQH9M6)

**할 일**: 추후 iOS·Android 번들 ID를 **하나로 통일**한다(iOS 기준으로 맞추거나 단일 번들로 정리 — 방향은 착수 시 확정).

**주의(통일 시 파급)**: 번들 ID 변경은 Firebase 앱 재등록(google-services.json·GoogleService-Info.plist 교체), App Distribution 앱/릴리스 새로 생성, iOS 프로비저닝 프로파일 재발급, 스토어 등록(App Store/Play Console) 시 앱 식별자 영향까지 연쇄됨. 배포 이력·테스터 그룹이 새 번들로 이관되어야 하므로 배포 공백을 감안해 계획적으로 진행.

## 배포 기록 — 1.0.0+2 (2026-07-27)

PR #6~#11 반영분을 iOS·Android 동시 배포. **배포 경로는 Firebase App Distribution 단일 — TestFlight는 쓰지 않는다**(사용자 결정 2026-07-27).

- **버전**: `1.0.0+2` (직전 배포 `1.0.0+1`, 2026-07-20)
- **iOS**: ad-hoc 서명 IPA 16MB · Firebase 앱 `1:771540934251:ios:6467ee8681bd69fd1d1b2e`
- **Android**: release APK 61MB(**debug 키 서명** — Play 스토어엔 부적합) · Firebase 앱 `1:771540934251:android:53eca952be5c43d41d1b2e`
- **테스터**: 그룹이 없어 `--testers`로 3명 직접 지정 (`dlgustjd9566@gmail.com`, `earthlm5@naver.com`, `wotjd716400@gmail.com`)
- **게이트**: `flutter analyze` 0건 · `flutter test` 83개 통과

**재현 명령**

```bash
flutter build ipa --release --export-method ad-hoc
flutter build apk --release
firebase appdistribution:distribute build/ios/ipa/deck_119.ipa \
  --app 1:771540934251:ios:6467ee8681bd69fd1d1b2e \
  --release-notes-file <notes> --testers "<emails>" --project deck-119
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:771540934251:android:53eca952be5c43d41d1b2e \
  --release-notes-file <notes> --testers "<emails>" --project deck-119
```

**주의(iOS ad-hoc)**: 프로비저닝 프로파일(`iOS Team Ad Hoc Provisioning Profile: com.hyeonseong.fireDeck`, 만료 2027-07-17)에 등록된 **UDID 5대에서만** 설치된다. 미등록 기기는 배포 메일을 받아도 설치가 실패하므로 테스터 추가 시 기기 등록 → 프로파일 재발급 → 재빌드가 필요하다. Android는 이 제약이 없다.

**기기 등록 확인**: 테스터 2명(재성 김)의 기기는 위 5대에 포함되어 있다(사용자 확인 2026-07-27). 이후 **새 테스터**를 추가할 때만 위 재발급 절차가 필요하다.

**빌드 부산물 주의**: `flutter build ipa`가 `ios/Runner.xcodeproj/project.pbxproj`의 `objectVersion`을 60 → 54로 되쓴다. 요청과 무관한 변경이므로 배포 후 `git checkout --`로 되돌린다.

**로컬 worker**: 배포 후 재기동 = `launchctl kickstart -k gui/$(id -u)/com.seong.deck119.worker`. 로그 `~/Library/Logs/deck119-worker.log`, 기동 로그 문구 `worker up (claude→codex 폴백). watching gen_requests(status=pending)…`.

### 운영 결정 (2026-07-27, 사용자 확정)

- **테스터 그룹은 만들지 않는다** — 3명 규모라 `--testers`에 이메일을 나열하는 현 방식으로 충분. 인원이 늘면 그때 그룹 도입을 재검토.
- **Play 스토어 출시 계획 없음** — 따라서 Android release가 debug 키로 서명되는 현 상태(`android/app/build.gradle.kts` release 블록의 TODO)를 그대로 둔다. 출시가 정해지면 keystore 발급 → `android/key.properties` 구성 → release signingConfig 교체가 선행 과제.

---

## 풀이 이력 영속화 v2 — AI 문제함 이력 + 전 모드 이어풀기 ✅ (2026-08-02)

계획서: `docs/PLAN_resume_v2.md` (인터뷰로 확정한 결정 표 포함). 브랜치 `fix/ai-history-and-resume`.

### 보고된 문제와 실제 원인

두 증상은 한 뿌리 — **AI 모드에 풀이 상태를 저장하는 경로가 없었다.**

1. "새로 발급하면 이전에 푼 문제가 다시 미풀이로 나온다" → 정답이 날아간 게 아니라 **애초에 저장된 적이 없다.** `quiz_view_model.dart`의 `if (arg.mode != QuizMode.ai)` 가드로 AI 문항은 `SubmitAnswer`를 타지 않았고(통계·오답노트 오염 방지 — ADR-0002), 그 결과 진입할 때마다 `index: 0` / `answers` 전부 null.
2. "풀다가 나가면 처음부터" → 세션 저장이 `QuizMode.normal` 전용이었고 `Sessions.key`도 `"$categoryId:normal"` 하드코딩이라 다른 모드용 슬롯 자체가 없었다.

부수 발견(같이 수정): 적립함 `getAll()`이 최신순이라 새 문항이 목록 맨 앞에 붙었다 → 인덱스 기반 저장은 생성할 때마다 전부 밀려 깨지므로 **questionId 기반**이 필수. `set_mode_page`의 이어풀기 타일이 세션 모드와 무관하게 항상 `normal`로 진입하던 버그, `/exam` 라우트가 `resume`을 받지 않아 시험 이어풀기가 처음부터 시작되던 문제도 함께 고쳤다.

### 변경 요약

- **스키마 v5**: `Sessions`에 `mode`·`questionIds` 추가(랜덤·빠른10·오답은 출제 목록 자체를 저장해야 복원됨), `AiAnswers` 테이블 신설. **기존 세션은 삭제하지 않는다**(v4의 `DELETE FROM sessions`와 달리 컬럼만 추가).
- **AI 문제함**: `AiAnswers`가 진행 상태의 원천. 홈 진입 시 이미 푼 문항이 있으면 이어풀기(전체 목록 유지 + 첫 미풀이로 점프) / 처음부터(기록 전체 초기화)를 묻는다. 적립함 정렬은 생성순(ASC)으로 변경. 통계·오답노트는 여전히 기출만 집계.
- **전 모드 이어풀기**: `GetQuizSession` UseCase가 세트 구성·복원을 일원화. 시험 모드는 제출 전까지 임시저장하고 제출 시 세션 삭제. 오답 재풀이는 시작 시점 목록 고정.
- **홈·세트 화면**: 이어풀기 카드에 모드 라벨(`이어풀기 · 랜덤`)을 붙이고 그 모드로 진입. AI 문제함 카드에 `미풀이 N문항` 표시.
- **결과 화면**: ai 모드에서는 '다시 풀기'를 숨겼다 — 시작 방식은 홈 다이얼로그가 관장하며, 그대로 두면 이미 채점된 답이 보이는 채로 재시작된다.

### 검증

`flutter analyze` 이슈 0 · `flutter test` **106개 통과**(작업 전 기준선 83 → +23).

신규: `drift_ai_answer_test`(기록 왕복·과목별 초기화·생성순 정렬·미풀이 수 스트림), `ai_resume_flow_test`(문제 1 회귀 — 2문항 풀고 이탈 → 2문항 추가 발급 → 답 유지 + 3번부터), `get_quiz_session_test`(문항 소실 시 답·위치 보정, 전부 소실 시 세션 폐기, 구 세션 하위호환), `session_migration_test`의 v4→v5 케이스.
확장: `resume_flow_test`(선택 즉시 저장 / 랜덤 세트 순서 복원 / 시험 임시저장·제출 시 삭제), `drift_session_test`(모드별 분리·출제 목록·카테고리 필터), `home_reactive_test`(모드 라벨 진입, AI 다이얼로그 2종).

### 에뮬레이터 검증 (Android 14 / emulator-5554, 2026-08-02)

**실제 v4 → v5 업그레이드 경로**로 확인했다. `main` 브랜치를 worktree에 체크아웃해 구버전 APK를 먼저 설치 → 화재조사법 세트를 3/9까지 풀어 v4 세션을 만들고(`PRAGMA user_version` = 4) → 신버전 APK를 덮어씌워 데이터를 유지한 채 재실행.

| 확인 항목 | 결과 |
|---|---|
| 마이그레이션 | `user_version` 4 → 5, 기존 세션 행 보존(`mode='normal'`, `question_ids=''`), `ai_answers` 생성 |
| 구 세션 이어풀기 | 홈 카드 `이어풀기 · 전체 풀이 3/9` → 탭 시 3번 문항부터 정확히 복원 |
| 선택 즉시 저장(문제 2) | '다음'을 누르지 않고 답만 고른 뒤 이탈 → 재진입 시 선택·정답 판정·해설 그대로 복원(`answers`가 `0,0,0,…`) |
| 모드별 세션 분리 | `:normal`(정순)과 `:random`(셔플 목록)이 각각 저장, 홈 카드는 최근 것을 `이어풀기 · 랜덤 2/9`로 표시 |
| 랜덤 이어풀기 | 진입 시 저장된 셔플 순서의 2번째 문항부터 — 구버전에선 불가능했던 동작 |
| AI 문제함(문제 1) | 3문항 중 2문항 풀고 이탈 → 2문항 추가 발급 → 재진입 시 "5문항 중 2문항을 풀었어요" 다이얼로그 → 이어풀기 시 **3/5**부터, '이전'으로 가면 2번 답·해설 복원 |
| AI 처음부터 다시 | `ai_answers` 0건으로 초기화 + 1/5 미풀이 상태로 시작 |
| 통계 오염 | AI 문항 응답 후에도 `attempt_records`에 `ai-%` 0건 — ADR-0002 유지 확인 |

### 정직 보고 — 하지 않은 것

- ~~**AI 실제 생성은 돌리지 않았다.**~~ → **2026-08-03 해소.** 아래 §실제 생성 경로 e2e 검증 참조. (당시 기록의 "로컬 worker가 Firestore watch 에러로 멈춰 있다"는 **사실이 아니었다** — 8/03 실측 시 worker는 7/27부터 재시작 없이 정상 가동 중이었고 로그에 `watch error` 문구는 0건, `gen_requests`에 밀린 pending도 0건이었다. 7/31 이후 요청 자체가 없어 조용했던 것을 멈춘 것으로 오판했다.)
- **iOS 미확인.** 검증은 Android 에뮬레이터 한 대에서만 했다.
- 에뮬레이터에는 테스트 데이터(`ai-seed-1`~`5`, 세션 2건)가 남아 있다. 지우려면 앱 데이터 삭제(`adb shell pm clear com.seong.deck119`).
- 기존 `session_migration_test`의 v3→v4 케이스는 `onUpgrade(3, 4)`를 수동 호출하는 방식이었는데, 마이그레이션이 `to`가 아니라 `from`만 검사하는 구조라 v5 블록까지 실행돼 깨졌다. 실제 경로(v3 DB를 열면 3→5로 한 번에 간다)를 검증하도록 테스트를 다시 썼다.
- 테스트에서 `autoDispose` 파기 타이밍이 실기와 달라, AI 재진입 테스트는 `container.invalidate(quizViewModelProvider(args))`로 화면 이탈을 모사한다.

### 실제 생성 경로 e2e 검증 (Android 15 / Medium_Phone_API_35, 2026-08-03)

앞선 검증이 sqlite 주입 데이터였던 것과 달리, **앱 UI에서 실제로 AI 생성을 2회 돌려** 생성 → 적립 → 풀이 기록 → 이어풀기를 통으로 확인했다. 앱 미설치 클린 AVD에서 시작(실기기는 배포판 v1.0.0이 깔려 있어 디버그 빌드 설치 시 서명 불일치로 데이터가 지워지므로 제외).

| 확인 항목 | 결과 |
|---|---|
| 요청 제출 | 앱 → `gen_requests` doc 생성 → worker가 즉시 claim (1차 `IwjWjXsi3PEz5cHVpa6a` mcq×10, 2차 `ycyiJ8FrelS8fWh128sR` ox×10) |
| 적립 | `generated_questions` 10 → 20건, 생성순(ASC) 정렬로 새 문항이 **뒤에** 쌓임 |
| 홈 카드 | `누적 10 · 미풀이 10` → 3문항 풀이 후 `미풀이 7` → 10문항 추가 발급 후 `누적 20 · 미풀이 17` |
| 첫 진입 | 푼 문항 0이면 다이얼로그 없이 1번부터 |
| 선택 즉시 저장 | 이탈 확정 **전에** 이미 `ai_answers` 3행 기록됨 |
| 재진입 다이얼로그 | `20문항 중 3문항을 풀었어요` + 초기화 경고 문구 |
| **문제 1 회귀** | 이어풀기 → **4/20**(첫 미풀이). 새 10문항 발급 후에도 기존 3문항 기록 유지, 위치도 안 밀림 |
| 복습 | '이전'으로 3번 이동 시 선택·정답·해설 완전 복원 |
| 통계 오염 | `attempt_records` 0건, 홈 `푼 문제 0` — ADR-0002 유지 |
| 스키마 | 신규 설치 `PRAGMA user_version` = 5 |

**발견(미수정, 이번 범위 밖)**: `worker/index.js`의 `onSnapshot` 에러 콜백이 `console.error`만 하고 재구독하지 않는다. Firestore Node SDK는 이 콜백이 발화하는 순간 리스너를 영구 종료하므로, 한 번 발생하면 프로세스는 살아 있는 채로 요청을 영영 못 받는다(로그를 안 보면 감지 불가). 재구독 또는 주기적 pending 폴링 안전망이 필요하다.

**잔여 테스트 데이터**: Firestore `gen_requests`에 이번 검증 doc 3건(`3g6luOY7eBQj3f5r99jc` 직접 투입 1건 + 앱 요청 2건). 에뮬레이터는 종료했고 앱 데이터는 그대로다.
