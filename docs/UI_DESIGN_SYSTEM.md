# 119덱 UI 디자인 시스템 (MVP)

> 방향 = **차분한 뉴트럴 + 소방 레드 액센트**. 장시간 문제풀이에 눈이 편한 중립 표면 위에, 소방 정체성(레드)은 **상단바·진행바·주요 버튼·선택 포인트**에만 절제해 쓴다. 정답=초록/오답=레드로 명확히.
> 구현 = 순수 Flutter **Material 3 + ThemeExtension**(새 의존성 0). 모든 화면·위젯은 이 토큰·컴포넌트만 쓰고 **화면별 색/간격 하드코딩 금지**.
> 위치: `lib/presentation/shared/theme/`(토큰) · `lib/presentation/shared/widgets/`(공용 컴포넌트).

## 1. 원칙

- **가독 우선**: 문항 지문이 주인공. 큰 글씨·넉넉한 행간·충분한 여백.
- **한 곳에만 대담하게**: 레드는 액센트로만. 나머지는 조용한 중립.
- **색은 단독 신호가 아님**: 정답/오답은 색 + **아이콘(✓/✕)** 동시(접근성).
- **한 손 조작**: 주요 액션은 하단 고정(SafeArea), 엄지 도달권.
- **라이트/다크 동등**: 모든 토큰에 다크 값. 어느 쪽도 임시방편 아님.

## 2. 컬러 토큰 (DESIGN_HANDOFF §1 확정값 — 목업 추출)

`ColorScheme.fromSeed(seedColor: brand)` 기반 + 커스텀 `AppColors` ThemeExtension으로 의미색 보강. 라이트/다크 **동등**.

### 브랜드/액센트
- `brand` = **#C6402E**(라이트) / **#E86B4E**(다크). 용도: 상단바·진행바 fill·선택 링·**주요 버튼(FilledButton)**·이어풀기. 과용 금지.
- `brandInk` #A8331F / #F08770 (브랜드 텍스트·아이콘) · `brandTint` #F8EAE5 / #3A241D (이어풀기 배경·연면).

### 중립 표면·경계
| 토큰 | Light | Dark |
|---|---|---|
| background(bg) | #F4F5F7 | #131417 |
| surface(카드) | #FFFFFF | #1B1D20 |
| surfaceVariant(surfaceAlt) | #F5F6F8 | #232529 |
| outline | #E3E5E9 | #2E3136 |
| outlineStrong | #CFD2D8 | #3C4046 |
| textPrimary(text) | #181A1D | #E9EAEC |
| textSecondary | #5C6068 | #9DA2AA |
| textTertiary | #9297A0 | #6E727A |

### 의미색 (AppColors ThemeExtension)
| 토큰 | Light | Dark | 용도 |
|---|---|---|---|
| correct / correctInk / onCorrect(tint) | #157347 / #0E5A38 / #E6F3EC | #4FC189 / #74D3A3 / #1C3226 | 정답 타일·배너 |
| wrong / wrongInk / onWrong(tint) | #BE3455 / #9E2846 / #F9E9ED | #E86A82 / #F08D9F / #37222A | 오답 타일·배너 |
| sel / selTint | #181A1D / #EBEDF0 | #E9EAEC / #26282C | 시험모드 중립 선택·진행바 트랙·배지 배경 |
| selectedRing | brand | brand | 선택 표시 |
| shadow | rgba(0,0,0,.05) | rgba(0,0,0,.4) | 카드 미세 그림자 |

> ⚠️ 오답(#BE3455 마젠타톤)과 브랜드(#C6402E 오렌지레드)는 톤을 분리하고, 오답은 **항상 ✕ 아이콘**과 함께 → 버튼(브랜드)과 혼동 방지.

## 3. 타이포그래피 — Pretendard 번들(4 weight: 400/500/600/700)

`ThemeData.fontFamily: 'Pretendard'`로 전역 상속. 스케일 고정 — 임의 크기 금지. (800 요청 시 등록된 700로 근사.)

| 역할 | 크기/굵기/행간/자간 | 쓰임 |
|---|---|---|
| score | 56 / w800 / 1.0 | 결과 점수 |
| scoreUnit | 28 / w700 | 점수 단위(" / N", textTertiary) |
| titleScreen | 22 / w800 | 화면 제목(설정·과목) |
| logo | 26 / w800 | 홈 로고 |
| subjectName | 22 / w800 | 홈 선택 과목명 |
| **stem** | 19 / w600 / 1.55 / -0.01em | **문항 지문(핵심)** |
| choice | 16 / w600 | 선택지 |
| oxGlyph | 46 / w700 | OX 큰 글자 |
| body | 15 / w400 / 1.7 | 해설·본문 |
| label(labelStrong) | 12 / w700 / +0.06em | 라벨·배지·섹션헤더 |
| tab | 11 / w500(활성 w700) | 하단 탭 라벨 |
| caption | 13 / w500 | 보조(secondary color) |

## 4. 간격·모서리·그림자

- **spacing**(4 배수): `xs 4 · sm 8 · md 12 · lg 16 · xl 20 · xxl 24 · huge 32`. 화면 좌우 패딩 = xl(20).
- **radius**: `badge 8 · md 12 · tile 14 · card 16 · lg 16 · ox 20 · iconBadge 28 · pill 999`.
- **elevation**: 기본 **평면** + 미세 `shadow` 토큰(그림자 남발 금지). 대부분 1px outline.

## 5. 공용 컴포넌트 (shared/widgets)

각 항목은 Flutter 위젯으로 구현하고 화면은 이것만 조합한다.

- **AppScaffold** — 일관된 AppBar(타이틀 w700, 배경 surface, 하단 1px outline)·좌우 lg 패딩·배경 background.
- **QuestionCard** — surface 카드(radius md, 1px outline). 상단 라벨행(`위치 N/총` + **TypeBadge**), 그 아래 stem(타이포 stem). 패딩 lg.
- **TypeBadge** — 작은 pill. mcq="객관식"(neutral) / ox="OX"(brand 외곽선). label 타이포.
- **ChoiceTile** — 전폭, 최소높이 52, radius md, 좌측정렬 choice 타이포, 탭영역 ≥48dp. 상태:
  - idle: surface + 1px outline
  - pressed: surfaceVariant
  - selected(채점 전): outline=brand 2px (selectedRing)
  - correct: correct 배경 + ✓ 아이콘 + onCorrect 텍스트
  - wrong: wrong 배경 + ✕ 아이콘 + onWrong 텍스트
  - 채점 후 전 타일 비활성(onTap null), 정답 타일은 항상 correct 강조
- **AnswerBanner** — 채점 직후 "정답입니다 ✓" / "오답입니다 ✕" (correct/wrong 색+아이콘), 해설 위.
- **ExplanationCard** — surfaceVariant 배경, "해설" label + body. 채점 후에만.
- **PrimaryButton** — FilledButton, 높이 52, radius md, brand. 하단 고정(SafeArea, 좌우 lg). "다음"·"결과 보기"·"제출".
- **SecondaryButton** — tonal/outlined neutral. "다시 풀기"·"홈으로".
- **ProgressHeader** — LinearProgressIndicator(brand, track=surfaceVariant) + 우측 `N / 총` label. 풀이·시험 상단 고정.
- **ScoreView** — 큰 score 타이포 `정답수 / 총` + 보조 캡션(정답률 %).
- **ModeTile**(홈) — 과목 카드 내 모드 진입행: 아이콘 + 라벨(전체/랜덤/오답/시험) + 짧은 설명. 이어풀기 있으면 상단 강조 타일.
- **EmptyState** — 중앙 아이콘 + 안내문("풀 오답이 없어요"). 오답 재풀이 빈 상태 등.
- **SettingTile / ThemeRadioGroup** — 설정 화면 라디오(시스템/라이트/다크).

## 6. 화면 레이아웃 원칙

- 단일 컬럼, 좌우 lg(16) 패딩. 태블릿은 본문 max-width ~600 중앙 정렬.
- 상단: ProgressHeader 고정(풀이·시험). 본문: 스크롤. 하단: PrimaryButton 고정(SafeArea).
- 홈: 과목 카드 → (이어풀기) → 모드 타일 목록 → 우상단 설정 아이콘.
- 결과: ScoreView → 오답 리뷰 리스트(문항·내 답·정답·해설) → Secondary(다시/홈).

## 7. 모션·접근성

- 모션 최소: 선택 채점 색전환 150ms ease. 페이지 전환 기본. `MediaQuery.disableAnimations` 존중.
- 탭 타깃 ≥48dp. 명도대비 AA. 정답/오답은 **색+아이콘+텍스트** 3중.
- 텍스트 스케일(`textScaler`) 대응 — 고정 높이 대신 min 제약.

## 8. Do / Don't

- ✅ 색·간격·타이포는 **토큰에서만**. 컴포넌트는 shared/widgets 재사용.
- ✅ 레드는 액센트·주요버튼·정답오답에만.
- ❌ 화면 파일에서 `Color(0x..)`·매직 패딩 하드코딩.
- ❌ 레드를 배경 전면·대면적에 사용(피로).
- ❌ 정답/오답을 색만으로 구분(아이콘 필수).

## 9. 구현 매핑 (태스크)

- **T9(파운데이션, T1 다음 실행)**: `shared/theme/`에 ColorScheme+AppColors ThemeExtension·타이포·spacing/radius 상수, `shared/widgets/`에 §5 컴포넌트. 기존 `app_theme.dart`·`quiz_page.dart`의 인라인 ChoiceTile을 공용 컴포넌트로 승격.
- 이후 T3(시험)·T5(설정)·T7(결과)와 홈/풀이 화면은 **전부 이 컴포넌트로** 구성.
- DoD: 다크/라이트 양쪽 렌더 확인 · `flutter analyze` 0 · 하드코딩 색/간격 없음.
