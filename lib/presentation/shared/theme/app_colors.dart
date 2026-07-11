import 'package:flutter/material.dart';

/// 의미색·중립 표면 토큰(DESIGN_HANDOFF §1.1/§1.2). ColorScheme를 보강하는
/// ThemeExtension. 화면·위젯은 `context.colors`로만 색을 읽는다(하드코딩 금지).
/// 라이트/다크는 동등 — 두 세트를 모두 목업 확정값으로 담는다.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  // 표면 · 경계
  final Color background; // bg
  final Color surface;
  final Color surfaceVariant; // surfaceAlt(지문 박스 등 보조 표면)
  final Color outline;
  final Color outlineStrong; // 강조 경계(secondary 버튼)

  // 텍스트
  final Color textPrimary; // text
  final Color textSecondary;
  final Color textTertiary; // 캡션·비활성

  // 브랜드
  final Color brand; // 액센트·주요 버튼·진행바
  final Color brandInk; // 브랜드 텍스트/아이콘(라벨)
  final Color brandTint; // 이어풀기 배경·브랜드 연면

  // 정답
  final Color correct; // 경계/아이콘
  final Color correctInk; // 텍스트
  final Color onCorrect; // correctTint(배경)

  // 오답
  final Color wrong; // 경계/아이콘
  final Color wrongInk; // 텍스트
  final Color onWrong; // wrongTint(배경)

  // 중립 강조(시험모드 선택 등)
  final Color sel;
  final Color selTint; // 진행바 트랙·배지 배경·스켈레톤

  final Color selectedRing; // 선택 과목 링 = brand
  final Color shadow; // 카드 미세 그림자 색

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.outlineStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.brand,
    required this.brandInk,
    required this.brandTint,
    required this.correct,
    required this.correctInk,
    required this.onCorrect,
    required this.wrong,
    required this.wrongInk,
    required this.onWrong,
    required this.sel,
    required this.selTint,
    required this.selectedRing,
    required this.shadow,
  });

  static const Color _brandLight = Color(0xFFC6402E);
  static const Color _brandDark = Color(0xFFE86B4E);

  static const AppColors light = AppColors(
    background: Color(0xFFF4F5F7),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF5F6F8),
    outline: Color(0xFFE3E5E9),
    outlineStrong: Color(0xFFCFD2D8),
    textPrimary: Color(0xFF181A1D),
    textSecondary: Color(0xFF5C6068),
    textTertiary: Color(0xFF9297A0),
    brand: _brandLight,
    brandInk: Color(0xFFA8331F),
    brandTint: Color(0xFFF8EAE5),
    correct: Color(0xFF157347),
    correctInk: Color(0xFF0E5A38),
    onCorrect: Color(0xFFE6F3EC),
    wrong: Color(0xFFBE3455),
    wrongInk: Color(0xFF9E2846),
    onWrong: Color(0xFFF9E9ED),
    sel: Color(0xFF181A1D),
    selTint: Color(0xFFEBEDF0),
    selectedRing: _brandLight,
    shadow: Color(0x0D000000), // rgba(0,0,0,.05)
  );

  static const AppColors dark = AppColors(
    background: Color(0xFF131417),
    surface: Color(0xFF1B1D20),
    surfaceVariant: Color(0xFF232529),
    outline: Color(0xFF2E3136),
    outlineStrong: Color(0xFF3C4046),
    textPrimary: Color(0xFFE9EAEC),
    textSecondary: Color(0xFF9DA2AA),
    textTertiary: Color(0xFF6E727A),
    brand: _brandDark,
    brandInk: Color(0xFFF08770),
    brandTint: Color(0xFF3A241D),
    correct: Color(0xFF4FC189),
    correctInk: Color(0xFF74D3A3),
    onCorrect: Color(0xFF1C3226),
    wrong: Color(0xFFE86A82),
    wrongInk: Color(0xFFF08D9F),
    onWrong: Color(0xFF37222A),
    sel: Color(0xFFE9EAEC),
    selTint: Color(0xFF26282C),
    selectedRing: _brandDark,
    shadow: Color(0x66000000), // rgba(0,0,0,.4)
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? outline,
    Color? outlineStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? brand,
    Color? brandInk,
    Color? brandTint,
    Color? correct,
    Color? correctInk,
    Color? onCorrect,
    Color? wrong,
    Color? wrongInk,
    Color? onWrong,
    Color? sel,
    Color? selTint,
    Color? selectedRing,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outline: outline ?? this.outline,
      outlineStrong: outlineStrong ?? this.outlineStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      brand: brand ?? this.brand,
      brandInk: brandInk ?? this.brandInk,
      brandTint: brandTint ?? this.brandTint,
      correct: correct ?? this.correct,
      correctInk: correctInk ?? this.correctInk,
      onCorrect: onCorrect ?? this.onCorrect,
      wrong: wrong ?? this.wrong,
      wrongInk: wrongInk ?? this.wrongInk,
      onWrong: onWrong ?? this.onWrong,
      sel: sel ?? this.sel,
      selTint: selTint ?? this.selTint,
      selectedRing: selectedRing ?? this.selectedRing,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandInk: Color.lerp(brandInk, other.brandInk, t)!,
      brandTint: Color.lerp(brandTint, other.brandTint, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      correctInk: Color.lerp(correctInk, other.correctInk, t)!,
      onCorrect: Color.lerp(onCorrect, other.onCorrect, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      wrongInk: Color.lerp(wrongInk, other.wrongInk, t)!,
      onWrong: Color.lerp(onWrong, other.onWrong, t)!,
      sel: Color.lerp(sel, other.sel, t)!,
      selTint: Color.lerp(selTint, other.selTint, t)!,
      selectedRing: Color.lerp(selectedRing, other.selectedRing, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// 화면·위젯에서 토큰 색을 읽는 진입점.
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
