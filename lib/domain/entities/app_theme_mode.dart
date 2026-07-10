/// 앱 테마 설정(도메인). Flutter의 ThemeMode와 분리 — presentation에서 매핑.
enum AppThemeMode {
  system,
  light,
  dark;

  /// 저장 문자열("system"|"light"|"dark") → enum. 미상값은 system.
  static AppThemeMode fromStorage(String? value) {
    return AppThemeMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  /// 저장 문자열.
  String get storageValue => name;
}
