import 'package:drift/drift.dart';

import 'app_database.dart';

/// 이어풀기 세션의 Drift 저장소. key = `"$subjectId:normal"`.
/// (구 IsarSessionDataSource 대체 — 시그니처 동일)
class DriftSessionDataSource {
  final AppDatabase _db;
  DriftSessionDataSource(this._db);

  String _key(String subjectId) => '$subjectId:normal';

  /// answers(`List<int>`, -1 = 미응답) ↔ CSV 문자열 직렬화.
  static String _encode(List<int> a) => a.join(',');
  static List<int> _decode(String s) =>
      s.isEmpty ? const [] : s.split(',').map(int.parse).toList();

  Future<({int lastIndex, List<int> answers})?> load(String subjectId) async {
    final row = await (_db.select(_db.sessions)
          ..where((t) => t.key.equals(_key(subjectId))))
        .getSingleOrNull();
    if (row == null) return null;
    return (lastIndex: row.lastIndex, answers: _decode(row.answers));
  }

  Future<void> save(
    String subjectId,
    int lastIndex,
    List<int> answers, {
    required int nowMs,
  }) async {
    await _db.into(_db.sessions).insertOnConflictUpdate(
          SessionsCompanion.insert(
            key: _key(subjectId),
            subjectId: subjectId,
            lastIndex: lastIndex,
            answers: _encode(answers),
            updatedAtMs: nowMs,
          ),
        );
  }

  Future<void> clear(String subjectId) async {
    await (_db.delete(_db.sessions)..where((t) => t.key.equals(_key(subjectId))))
        .go();
  }

  /// 최근 갱신순 세션(홈 이어풀기용). subjectId = 컬렉션 id.
  Future<List<({String subjectId, int lastIndex, int updatedAtMs})>> recent(
      int limit) async {
    final rows = await (_db.select(_db.sessions)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAtMs)])
          ..limit(limit))
        .get();
    return [
      for (final r in rows)
        (
          subjectId: r.subjectId,
          lastIndex: r.lastIndex,
          updatedAtMs: r.updatedAtMs,
        ),
    ];
  }
}
