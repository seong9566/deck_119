import 'package:flutter/material.dart';

/// 앱 테마. 소방 레드 시드. 다크모드 지원(PRD Must).
class AppTheme {
  static const _seed = Color(0xFFD32F2F);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
      );
}
