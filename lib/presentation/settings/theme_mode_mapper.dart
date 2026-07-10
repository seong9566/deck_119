import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_mode.dart';

/// 도메인 [AppThemeMode] ↔ Flutter [ThemeMode] 매핑(경계는 presentation).
extension AppThemeModeX on AppThemeMode {
  ThemeMode get material => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}

extension ThemeModeX on ThemeMode {
  AppThemeMode get app => switch (this) {
        ThemeMode.system => AppThemeMode.system,
        ThemeMode.light => AppThemeMode.light,
        ThemeMode.dark => AppThemeMode.dark,
      };
}
