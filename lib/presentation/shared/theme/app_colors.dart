import 'package:flutter/material.dart';

/// 의미색·중립 표면 토큰(UI_DESIGN_SYSTEM §2). ColorScheme를 보강하는
/// ThemeExtension. 화면·위젯은 `context.colors`로만 색을 읽는다(하드코딩 금지).
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color brand;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;
  final Color textPrimary;
  final Color textSecondary;
  final Color correct;
  final Color onCorrect;
  final Color wrong;
  final Color onWrong;
  final Color selectedRing;

  const AppColors({
    required this.brand,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.textPrimary,
    required this.textSecondary,
    required this.correct,
    required this.onCorrect,
    required this.wrong,
    required this.onWrong,
    required this.selectedRing,
  });

  static const Color _brand = Color(0xFFD32F2F);

  static const AppColors light = AppColors(
    brand: _brand,
    background: Color(0xFFFAFAF9),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2F1EF),
    outline: Color(0xFFE4E2DE),
    textPrimary: Color(0xFF1A1917),
    textSecondary: Color(0xFF6B6862),
    correct: Color(0xFF2E7D32),
    onCorrect: Color(0xFFE7F4E9),
    wrong: Color(0xFFC62828),
    onWrong: Color(0xFFFBE9E9),
    selectedRing: _brand,
  );

  static const AppColors dark = AppColors(
    brand: _brand,
    background: Color(0xFF131211),
    surface: Color(0xFF1C1B1A),
    surfaceVariant: Color(0xFF26241F),
    outline: Color(0xFF3A3833),
    textPrimary: Color(0xFFECEAE6),
    textSecondary: Color(0xFFA5A199),
    correct: Color(0xFF7FD48B),
    onCorrect: Color(0xFF17301A),
    wrong: Color(0xFFF1A0A0),
    onWrong: Color(0xFF331717),
    selectedRing: _brand,
  );

  @override
  AppColors copyWith({
    Color? brand,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? outline,
    Color? textPrimary,
    Color? textSecondary,
    Color? correct,
    Color? onCorrect,
    Color? wrong,
    Color? onWrong,
    Color? selectedRing,
  }) {
    return AppColors(
      brand: brand ?? this.brand,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outline: outline ?? this.outline,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      correct: correct ?? this.correct,
      onCorrect: onCorrect ?? this.onCorrect,
      wrong: wrong ?? this.wrong,
      onWrong: onWrong ?? this.onWrong,
      selectedRing: selectedRing ?? this.selectedRing,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      brand: Color.lerp(brand, other.brand, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      correct: Color.lerp(correct, other.correct, t)!,
      onCorrect: Color.lerp(onCorrect, other.onCorrect, t)!,
      wrong: Color.lerp(wrong, other.wrong, t)!,
      onWrong: Color.lerp(onWrong, other.onWrong, t)!,
      selectedRing: Color.lerp(selectedRing, other.selectedRing, t)!,
    );
  }
}

/// 화면·위젯에서 토큰 색을 읽는 진입점.
extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
