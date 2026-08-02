import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// 이어풀기 세션의 Drift 저장소. key = `"$categoryId:$mode"`.
class DriftSessionDataSource {
  final AppDatabase _db;
  DriftSessionDataSource(this._db);

  String _key(String categoryId, String mode) => '$categoryId:$mode';

  /// answers(`List<int>`, -1 = 미응답) ↔ CSV 문자열 직렬화.
  static String _encode(List<int> a) => a.join(',');
  static List<int> _decode(String s) =>
      s.isEmpty ? const [] : s.split(',').map(int.parse).toList();

  /// 출제 목록 ↔ JSON 배열. 빈 목록은 ''(= 저장소 순서 사용).
  static String _encodeIds(List<String> ids) =>
      ids.isEmpty ? '' : jsonEncode(ids);
  static List<String> _decodeIds(String s) => s.isEmpty
      ? const []
      : [for (final e in jsonDecode(s) as List) e as String];

  Future<({int lastIndex, List<int> answers, List<String> questionIds})?> load(
    String categoryId,
    String mode,
  ) async {
    final row = await (_db.select(_db.sessions)
          ..where((t) => t.key.equals(_key(categoryId, mode))))
        .getSingleOrNull();
    if (row == null) return null;
    return (
      lastIndex: row.lastIndex,
      answers: _decode(row.answers),
      questionIds: _decodeIds(row.questionIds),
    );
  }

  Future<void> save(
    String categoryId,
    String mode,
    int lastIndex,
    List<int> answers,
    List<String> questionIds, {
    required int nowMs,
  }) async {
    await _db.into(_db.sessions).insertOnConflictUpdate(
          SessionsCompanion.insert(
            key: _key(categoryId, mode),
            subjectId: categoryId,
            mode: Value(mode),
            questionIds: Value(_encodeIds(questionIds)),
            lastIndex: lastIndex,
            answers: _encode(answers),
            updatedAtMs: nowMs,
          ),
        );
  }

  Future<void> clear(String categoryId, String mode) async {
    await (_db.delete(_db.sessions)
          ..where((t) => t.key.equals(_key(categoryId, mode))))
        .go();
  }

  /// 최근 갱신순 세션(홈 이어풀기용). subjectId = 컬렉션 id.
  /// [categoryId]를 주면 그 카테고리의 세션만(모드 무관).
  Future<List<({String subjectId, String mode, int lastIndex, int total, int updatedAtMs})>>
      recent(int limit, {String? categoryId}) async {
    final q = _db.select(_db.sessions)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAtMs)])
      ..limit(limit);
    if (categoryId != null) {
      q.where((t) => t.subjectId.equals(categoryId));
    }
    final rows = await q.get();
    return [for (final r in rows) _toRecent(r)];
  }

  /// 최근 갱신순 세션 스트림(홈 이어풀기용). subjectId = 컬렉션 id.
  Stream<List<({String subjectId, String mode, int lastIndex, int total, int updatedAtMs})>>
      watchRecent(int limit) {
    return (_db.select(_db.sessions)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAtMs)])
          ..limit(limit))
        .watch()
        .map((rows) => [for (final r in rows) _toRecent(r)]);
  }

  static ({String subjectId, String mode, int lastIndex, int total, int updatedAtMs})
      _toRecent(Session r) => (
            subjectId: r.subjectId,
            mode: r.mode,
            lastIndex: r.lastIndex,
            total: _decodeIds(r.questionIds).length,
            updatedAtMs: r.updatedAtMs,
          );
}
