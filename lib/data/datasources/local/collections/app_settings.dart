import 'package:isar/isar.dart';

part 'app_settings.g.dart';

/// 앱 설정 단일 레코드(BUILD_PLAN §2). id 고정(=0).
@collection
class AppSettings {
  /// 단일 레코드 고정 id.
  Id id = 0;

  /// 테마 모드: `"light" | "dark" | "system"`(기본 `"system"`).
  late String themeMode;
}
