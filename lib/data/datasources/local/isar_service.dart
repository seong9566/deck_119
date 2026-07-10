import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'collections/app_settings.dart';
import 'collections/attempt_record.dart';
import 'collections/session_state.dart';
import 'collections/wrong_entry.dart';

/// Isar 인스턴스 부트스트랩(BUILD_PLAN §2). 앱 시작 시 1회 open.
class IsarService {
  IsarService._();

  /// 모든 쓰기 컬렉션 스키마.
  static const _schemas = [
    WrongEntrySchema,
    AttemptRecordSchema,
    SessionStateSchema,
    AppSettingsSchema,
  ];

  /// 앱 문서 디렉터리에 Isar를 연다.
  static Future<Isar> open() async {
    final existing = Isar.getInstance();
    if (existing != null) return existing;
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(_schemas, directory: dir.path);
  }
}
