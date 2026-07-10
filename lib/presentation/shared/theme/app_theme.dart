import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// 앱 테마(UI_DESIGN_SYSTEM). ColorScheme.fromSeed(소방 레드) + [AppColors]
/// ThemeExtension. 라이트/다크 동등 지원.
class AppTheme {
  static ThemeData light() => _build(AppColors.light, Brightness.light);
  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.brand,
      brightness: brightness,
    ).copyWith(
      primary: c.brand,
      onPrimary: Colors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      outline: c.outline,
      error: c.wrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.titleScreen.copyWith(color: c.textPrimary),
      ),
    );
  }
}
