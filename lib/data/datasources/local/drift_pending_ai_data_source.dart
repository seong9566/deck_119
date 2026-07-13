import 'package:drift/drift.dart';

import 'app_database.dart';

/// 회수 대기 요청(타임아웃 안전망)의 Drift 저장소.
class DriftPendingAiDataSource {
  final AppDatabase _db;
  DriftPendingAiDataSource(this._db);

  /// 생성 요청 기록(같은 docId면 덮어씀).
  Future<void> add(
    String docId, {
    required String subjectId,
    required String yearScope,
    required int nowMs,
  }) async {
    await _db.into(_db.pendingAiRequests).insertOnConflictUpdate(
          PendingAiRequestsCompanion.insert(
            docId: docId,
            subjectId: subjectId,
            yearScope: yearScope,
            createdAtMs: nowMs,
          ),
        );
  }

  /// 회수 완료·폐기 시 대기목록에서 제거.
  Future<void> remove(String docId) async {
    await (_db.delete(_db.pendingAiRequests)
          ..where((t) => t.docId.equals(docId)))
        .go();
  }

  /// 대기 요청 전체(오래된 순).
  Future<List<PendingAiRequest>> getAll() {
    return (_db.select(_db.pendingAiRequests)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAtMs)]))
        .get();
  }
}
