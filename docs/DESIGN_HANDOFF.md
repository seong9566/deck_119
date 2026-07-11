# 119덱 — 디자인 반영 핸드오프 (페이즈 2, 무인 빌드용 자체완결)

> **목표**: 클로드 디자인 목업(`docs/design/mockup.html`)의 비주얼·IA를 실제 Flutter 앱에 반영한다. 이 문서 하나로 완주 가능하게 토큰·화면지침·스코프 가드·태스크(DoD)를 담는다.
> **원천(SOT)**: 시각·토큰은 `docs/design/mockup.html`이 진실원. 이 문서와 목업이 충돌하면 **목업의 실제 값**을 따르되, §3 스코프 가드는 절대 우선.
> **성격**: MVP는 이미 기능 완주(페이즈 1, T1~T9). 페이즈 2는 **비주얼 리스킨 + 탭바 IA 도입**이다. 기능/로직 회귀 금지 — 화면과 토큰만 바꾼다.

---

## 0. 확정 결정 (변경 금지)

- **반영 범위** = **탭바 IA까지 채택**. 하단 탭바(홈·과목·설정) + 과목 화면 신설 포함.
- **폰트** = **Pretendard 번들**(에셋). 파일은 이미 `assets/fonts/`에 있음(Regular/Medium/SemiBold/Bold + OFL.txt). **pubspec 폰트 등록은 승인됨**(이 한정 예외 외 의존성/에셋 추가는 여전히 금지).
- 색·간격·타이포는 아래 §1 토큰만 사용. 화면 파일 하드코딩 금지(전부 `shared/theme` 경유).

## 1. 디자인 토큰 (목업에서 확정 추출 — 이 값을 그대로)

### 1.1 색 — 라이트
| 토큰 | 값 | 용도 |
|---|---|---|
| bg | #F4F5F7 | 화면 배경(scaffold) |
| surface | #FFFFFF | 카드·타일·바 |
| surfaceAlt | #F5F6F8 | 보조 표면(지문 박스) |
| outline | #E3E5E9 | 기본 경계 |
| outlineStrong | #CFD2D8 | 강조 경계(secondary 버튼) |
| text | #181A1D | 본문 |
| textSecondary | #5C6068 | 보조 |
| textTertiary | #9297A0 | 캡션·비활성 |
| **brand** | **#C6402E** | 액센트·주요 버튼·진행바·선택 과목 링 |
| brandInk | #A8331F | 브랜드 텍스트/아이콘(라벨) |
| brandTint | #F8EAE5 | 이어풀기 배경·브랜드 연면 |
| correct | #157347 | 정답 경계/아이콘 |
| correctInk | #0E5A38 | 정답 텍스트 |
| correctTint | #E6F3EC | 정답 배경 |
| wrong | #BE3455 | 오답 경계/아이콘 |
| wrongInk | #9E2846 | 오답 텍스트 |
| wrongTint | #F9E9ED | 오답 배경 |
| sel | #181A1D | 시험모드 선택 표시(중립 강조) |
| selTint | #EBEDF0 | 진행바 트랙·배지 배경·스켈레톤 |
| shadow | 0 1px 2px rgba(0,0,0,.05) | 카드 미세 그림자 |

### 1.2 색 — 다크
| 토큰 | 값 |
|---|---|
| bg | #131417 · surface #1B1D20 · surfaceAlt #232529 |
| outline #2E3136 · outlineStrong #3C4046 |
| text #E9EAEC · textSecondary #9DA2AA · textTertiary #6E727A |
| **brand #E86B4E** · brandInk #F08770 · brandTint #3A241D |
| correct #4FC189 · correctInk #74D3A3 · correctTint #1C3226 |
| wrong #E86A82 · wrongInk #F08D9F · wrongTint #37222A |
| sel #E9EAEC · selTint #26282C · shadow 0 1px 2px rgba(0,0,0,.4) |

> 라이트/다크는 **동등**. `AppColors` ThemeExtension에 두 세트를 넣고 `ColorScheme`도 brand 시드로 정합.

### 1.3 타이포 — Pretendard (weight/size/line-height)
| 역할 | 스펙 | 쓰임 |
|---|---|---|
| score | 800 / 56 / 1.0 | 결과 점수(단위 " / 25"는 28·textTertiary) |
| screenTitle | 800 / 22~24 | 화면 제목(설정·과목), 홈 로고 26 |
| subjectName | 800 / 22 | 홈 선택 과목명 |
| stem | 600 / 19 / 1.55 / -0.01em | **문항 지문(핵심)** |
| choice | 600 / 16 | 선택지 |
| oxGlyph | 700 / 46 | OX 큰 글자 |
| body | 400 / 15 / 1.7 | 해설·지문 라인(지문 라인은 1.65) |
| labelStrong | 700 / 11~13 / +0.02~0.08em | 라벨·배지·섹션헤더("풀이 모드"·"해설"·"선택한 과목") |
| tab | 11 / active 700·idle 500 | 하단 탭 라벨 |
| caption | 500 / 12~14 | 보조 정보 |

### 1.4 간격·모서리
- spacing 4배수: xs4 · sm8 · md12 · lg16 · xl20 · xxl24 · huge32. **화면 좌우 패딩 20**.
- radius: chip/full 999 · tile 14 · card 16 · badge 6~8 · ox 20 · icon-badge 28.
- elevation: 평면 + 미세 shadow(위 토큰). 그림자 남발 금지.

## 2. 화면 · IA 매핑

### 2.1 네비게이션 (go_router 재구성)
- **ShellRoute + 하단 탭바 3탭**: `/`(홈)·`/subjects`(과목)·`/settings`(설정). 탭바는 **이 3화면에서만** 표시.
- **풀스크린(탭바 없음)**: `/quiz`(normal·random·review)·`/exam`·결과. 상단에 닫기(✕)로 홈 복귀.
- 결과: 현재 QuizState 종료 상태를 화면으로. 별도 라우트 또는 quiz 내 종료뷰 — 기존 구조 최소 변경으로.

### 2.2 화면별 지침 (목업 대조)
| 화면 | 핵심 |
|---|---|
| **홈** `/` | 로고(119**덱**, 덱=brand) · **선택한 과목 카드**(라벨"선택한 과목"+과목명+메타, 우측 "전체 과목 →") · 이어풀기 타일(brandTint 배경, brand 1.5px, ▶ 아이콘, "정규 · N/총 이어서 풀기") · 섹션"풀이 모드" · **모드 2×2 그리드**(전체/랜덤/오답/시험, 각 아이콘+제목+설명, min-height 112) |
| **과목** `/subjects` | 제목"과목"+"풀 과목을 선택하세요" · 과목 카드 리스트(이름+메타+진행바+진행라벨, 선택 시 brand 링+✓). **실제 과목만**(§3-1) |
| **풀이** `/quiz` | 상단 진행헤더(모드라벨·"N / 25"·닫기✕ + 진행바 brand) · 배지(selTint pill) · stem · (지문 있으면 surfaceAlt 박스) · MC=세로 타일 / OX=2버튼(min-h132, 46px 글자) · 채점 후 정답 타일 correct+✓(pop), 내 오답 wrong+✕, 나머지 dimmed(opacity .5) · 해설(배너+카드 붙은 형태) · 하단 고정 버튼 |
| **시험** `/exam` | 풀이와 동일 골격, **채점 숨김**: 선택은 sel(중립 강조)+"선택함"만, 재선택 가능, 마지막 버튼 "제출하고 채점" |
| **결과** | 상단"채점 결과"+닫기 · score tag(만점=correct"만점·완벽 ✓" / 그외=selTint"수고했어요 ↗") · **56px 점수 " / 25"** · "정답률 %" · 점수바 · **오답 리뷰**(카드: 번호칩+지문 / "✕ 내 답"·"✓ 정답" 칩 / 점선 위 해설) · 만점이면 오답 대신 완벽 카드 · 하단 홈으로/다시 풀기 |
| **설정** `/settings` | 뒤로(←)+제목"설정" · 섹션"테마" 카드(시스템/라이트/다크 라디오, on=brand 7px 링) · 섹션"앱 정보"(버전 1.0.0 · 오픈소스 라이선스 →) · 푸터 "119덱 · 소방관계법규" |
| **오답 빈 상태** | correctTint 아이콘칩 ✓ · "풀 오답이 없어요" · 안내 · 홈으로 버튼 |
| **로딩** | 스켈레톤(배지/제목/카드/타일 selTint) + 하단 스피너(brand) "문항을 불러오는 중…" |
| **에러** | brandTint "!" 아이콘 · 카피 §3-2대로 조정 · 홈으로/다시 시도 |

### 2.3 아이콘 매핑 (flutter_svg 금지 — Material 아이콘으로 근사)
home→`home_outlined` · 과목/layers→`layers_outlined` · 설정/sliders→`tune` · 전체풀이/list→`format_list_numbered` · 랜덤→`shuffle` · 오답/refresh→`replay` · 시험/timer→`timer_outlined` · 이어풀기/play→`play_arrow_rounded` · 닫기→`close` · 뒤로→`arrow_back`. brand 색.

## 3. 스코프 가드 (무인 에이전트 절대 준수)

1. **실재 콘텐츠 = 소방관계법규 1과목만.** 목업의 4과목(소방학개론·행정법총론·소방전술)·done 카운트·진행률(%)은 **데모 더미다. 하드코딩 금지.** 과목 화면은 실제 과목만 렌더. 진행률은 실제 데이터(Isar) 있으면 표시, 없으면 생략(가짜 수치 만들지 말 것).
2. **에러 카피 = 오프라인 번들 앱에 맞게.** 목업의 "네트워크 연결을 확인"은 부적합(앱은 오프라인·에셋 번들). "문항을 불러오지 못했어요 / 다시 시도해 주세요"류로, 원인=에셋 로드 실패, 액션=재로드.
3. **설정 링크**: "오픈소스 라이선스"는 **실제 구현**(Pretendard OFL 고지 — `showLicensePage` 또는 라이선스 화면). 목업의 "문의하기"는 MVP 범위 밖 → **넣지 말 것**.
4. **기능/로직 회귀 금지.** 페이즈 2는 비주얼·IA만. 도메인/데이터/유스케이스 로직·오답 즉시제거·시험 일괄채점·이어풀기·설정 영속은 그대로. 색값 변경으로 기존 테스트 기대값이 깨지면 **기대값만** 갱신(로직 변경 아님).
5. **의존성 추가 금지**(기존 허용목록 유지). 예외 = Pretendard 폰트 pubspec 등록뿐. 커스텀 SVG 위해 flutter_svg 등 **추가 금지** → §2.3 Material 아이콘 사용.
6. **레이어 유지**: `domain`은 Flutter·Isar import 0. 리스킨은 `presentation`만. 토큰은 `shared/theme`, 컴포넌트는 `shared/widgets`.

## 4. 태스크 (실행 순서 · 각 DoD)

> 순서 = **T10 → T11 → T12 → T13 → T14 → T15 → T16**. 각 태스크: 구현 → `flutter analyze` 0 → 관련 테스트 통과 → `Closes: Tx` 커밋. 막힘/스킵은 `docs/BUILD_LOG.md`에 정직히.

- **T10. 토큰 + Pretendard 반영**
  - `pubspec.yaml` fonts 등록(아래 스니펫). `shared/theme`의 `AppColors`(라이트/다크)·타이포(`fontFamily: 'Pretendard'` + §1.3 스케일)·spacing/radius를 §1 값으로 교체. `ColorScheme` brand 시드 정합. `docs/UI_DESIGN_SYSTEM.md`를 새 토큰으로 갱신.
  - DoD: `flutter pub get` OK · `flutter analyze` 0 · 라이트/다크 렌더 테스트 통과(색 기대값 갱신).
- **T11. 공용 컴포넌트 리스킨** — ChoiceTile(mc/ox, idle/sel/correct/wrong/dimmed + ✓✕ pop 애니메이션 ~250ms)·QuestionCard(배지+stem+지문박스)·ExplanationCard(배너 붙은 형태)·ProgressHeader(닫기✕+brand 진행바)·PrimaryButton/SecondaryButton(disabled opacity .4)·ScoreView(56px+tag)·ReviewCard(번호칩+지문+내답/정답 칩+점선 해설)·EmptyState·ModeTile(2×2). 목업 대조.
  - DoD: `flutter analyze` 0 · `design_system_test` 라이트/다크 갱신·통과.
- **T12. 하단 탭바 + IA(go_router)** — ShellRoute + 하단 탭바(홈·과목·설정), 과목 화면 라우트 신설, 풀이/시험/결과는 풀스크린. 닫기(✕)로 홈 복귀.
  - DoD: `flutter analyze` 0 · 라우팅/탭 전환 위젯 테스트 · 기존 라우팅 테스트 갱신·유지.
- **T13. 홈 + 과목 화면** — 홈(선택 과목 카드·이어풀기·모드 2×2)·과목 화면(§3-1 실제 1과목). 목업 레이아웃.
  - DoD: `flutter analyze` 0 · 홈/과목 위젯 테스트(과목 노출·모드 진입·이어풀기).
- **T14. 풀이/시험 리스킨** — 목업 레이아웃대로. OX 2버튼 대형. 채점 색전환·✓✕ pop. 시험 채점숨김/제출.
  - DoD: `flutter analyze` 0 · 기존 풀이/시험 플로우 테스트 유지·통과.
- **T15. 결과/설정/빈·에러 리스킨** — 결과(점수 tag·오답 리뷰 카드)·설정(테마 라디오+앱정보+**오픈소스 라이선스**)·오답 빈 상태·에러(§3-2 카피).
  - DoD: `flutter analyze` 0 · 설정/결과 테스트 유지·통과.
- **T16. 최종 검증 + 보고** — `flutter analyze` 0 · `flutter test` 전부 통과. 목업 대비 반영/미반영을 `docs/BUILD_LOG.md`에 정직히. (가능하면 라이트/다크 스크린샷 언급.)

### pubspec fonts 스니펫 (T10)
```yaml
flutter:
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.otf
          weight: 400
        - asset: assets/fonts/Pretendard-Medium.otf
          weight: 500
        - asset: assets/fonts/Pretendard-SemiBold.otf
          weight: 600
        - asset: assets/fonts/Pretendard-Bold.otf
          weight: 700
```

## 5. 검증 런북
```bash
flutter pub get
flutter analyze          # 0
flutter test             # 전부 통과
```

## 6. 참조
- 목업 소스(SOT): `docs/design/mockup.html` (Read로 인라인 스타일·색·레이아웃 확인)
- 원본 목업(썸네일 포함 22MB): `~/Downloads/119덱.html` — 육안 확인은 브라우저로.
- 디자인 PRD(브리프): `docs/DESIGN_PRD.md`
- 기존 디자인 시스템(갱신 대상): `docs/UI_DESIGN_SYSTEM.md`
- 페이즈 1 빌드 계획: `docs/BUILD_PLAN.md`
