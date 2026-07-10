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

## 2. 컬러 토큰

`ColorScheme.fromSeed(seedColor: brand)` 기반 + 커스텀 `AppColors` ThemeExtension으로 의미색 보강.

### 브랜드/액센트
- `brand` = **#D32F2F** (소방 레드). 용도: 상단바 타이틀·진행바 fill·선택 링·**주요 버튼(FilledButton)**. 과용 금지.

### 중립 표면 (살짝 웜 바이어스 = 액센트와 정합)
| 토큰 | Light | Dark |
|---|---|---|
| background | #FAFAF9 | #131211 |
| surface(카드) | #FFFFFF | #1C1B1A |
| surfaceVariant | #F2F1EF | #26251F→#26241F |
| outline(경계) | #E4E2DE | #3A3833 |
| textPrimary | #1A1917 | #ECEAE6 |
| textSecondary | #6B6862 | #A5A199 |

### 의미색 (AppColors ThemeExtension)
| 토큰 | Light | Dark | 용도 |
|---|---|---|---|
| correct / onCorrect | #2E7D32 / #E7F4E9 | #7FD48B / #17301A | 정답 타일·배너 |
| wrong / onWrong | #C62828 / #FBE9E9 | #F1A0A0 / #331717 | 오답 타일·배너 |
| selectedRing | brand | brand | 채점 전 선택 표시 |

> ⚠️ 오답 레드(#C62828)와 브랜드 레드(#D32F2F)는 톤을 분리하고, 오답은 **항상 ✕ 아이콘**과 함께 → 버튼(브랜드)과 혼동 방지. 주요 버튼은 하단 채움 버튼으로만 등장.

## 3. 타이포그래피

시스템 폰트(한글은 OS 폰트로 렌더). 스케일 고정 — 임의 크기 금지.
> (선택·후속) Pretendard를 에셋 폰트로 번들하면 완성도↑ — 의존성 아님(pubspec fonts). MVP는 시스템 폰트.

| 역할 | 크기/굵기/행간 | 쓰임 |
|---|---|---|
| score | 34 / w700 | 결과 점수 |
| titleScreen | 22 / w700 | 화면 제목 |
| **stem** | 18 / w600 / 1.5 | **문항 지문(핵심)** |
| choice | 16 / w500 | 선택지 |
| body | 15 / w400 / 1.6 | 해설 본문 |
| label | 12 / w600 / +0.5sp | 라벨("해설"·"N/총"·배지) |
| caption | 13 / w400 | 보조(secondary color) |

## 4. 간격·모서리·그림자

- **spacing**(4 배수): `xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32`. 화면 좌우 패딩 = lg(16).
- **radius**: `sm 8 · md 12 · lg 16 · pill 999`. 카드·타일·버튼 기본 md(12).
- **elevation**: 기본 **평면**(그림자 대신 1px outline). 떠 보여야 할 때만 elevation 1. (차분함)

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
