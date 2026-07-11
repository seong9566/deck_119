import 'package:isar/isar.dart';

import 'collections/session_state.dart';

/// 이어풀기 세션의 Isar 저장소(BUILD_PLAN §2). key = `"$subjectId:normal"`.
class IsarSessionDataSource {
  final Isar _isar;
  IsarSessionDataSource(this._isar);

  String _key(String subjectId) => '$subjectId:normal';

  Future<({int lastIndex, List<int> answers})?> load(String subjectId) async {
    final row = await _isar.sessionStates.getByKey(_key(subjectId));
    if (row == null) return null;
    return (lastIndex: row.lastIndex, answers: row.answers);
  }

  Future<void> save(
    String subjectId,
    int lastIndex,
    List<int> answers, {
    required int nowMs,
  }) async {
    await _isar.writeTxn(() async {
      await _isar.sessionStates.putByKey(
        SessionState()
          ..key = _key(subjectId)
          ..subjectId = subjectId
          ..lastIndex = lastIndex
          ..answers = answers
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
