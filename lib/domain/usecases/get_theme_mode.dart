import '../entities/app_theme_mode.dart';
import '../repositories/settings_repository.dart';

/// 저장된 테마 모드 조회.
class GetThemeMode {
  final SettingsRepository _settings;
  GetThemeMode(this._settings);

  Future<AppThemeMode> call() => _settings.getThemeMode();
}
