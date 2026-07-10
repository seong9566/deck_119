import 'package:isar/isar.dart';

import 'collections/session_state.dart';

/// 이어풀기 세션의 Isar 저장소(BUILD_PLAN §2). key = `"$subjectId:normal"`.
class IsarSessionDataSource {
  final Isar _isar;
  IsarSessionDataSource(this._isar);

  String _key(String subjectId) => '$subjectId:normal';

  Future<int?> lastIndex(String subjectId) async {
    final row = await _isar.sessionStates.getByKey(_key(subjectId));
    return row?.lastIndex;
  }

  Future<void> save(String subjectId, int lastIndex, {required int nowMs}) async {
    await _isar.writeTxn(() async {
      await _isar.sessionStates.putByKey(
        SessionState()
          ..key = _key(subjectId)
          ..subjectId = subjectId
          ..lastIndex = lastIndex
          ..updatedAtMs = nowMs,
      );
    });
  }

  Future<void> clear(String subjectId) async {
    await _isar.writeTxn(() async {
      await _isar.sessionStates.deleteByKey(_key(subjectId));
    });
  }
}
