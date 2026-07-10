import '../entities/app_theme_mode.dart';

/// 앱 설정(테마) 포트. 구현은 data 레이어(Isar AppSettings 단일 레코드).
abstract interface class SettingsRepository {
  /// 저장된 테마 모드(기본 system).
  Future<AppThemeMode> getThemeMode();

  /// 테마 모드 저장.
  Future<void> setThemeMode(AppThemeMode mode);
}
