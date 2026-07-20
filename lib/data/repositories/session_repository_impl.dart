import 'dart:async';

import '../../domain/entities/recent_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/local/drift_session_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final DriftSessionDataSource _local;
  SessionRepositoryImpl(this._local);

  @override
  Future<({int lastIndex, List<int?> answers})?> load(String subjectId) async {
    final snap = await _local.load(subjectId);
    if (snap == null) return null;
    // 저장은 -1 sentinel, 도메인은 null 로 표현.
    return (
      lastIndex: snap.lastIndex,
      answers: [for (final a in snap.answers) a < 0 ? null : a],
    );
  }

  @override
  Future<void> save(String subjectId, int lastIndex, List<int?> answers) =>
      _local.save(
        subjectId,
        lastIndex,
        [for (final a in answers) a ?? -1],
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );

  @override
  Future<void> clear(String subjectId) => _local.clear(subjectId);

  @override
  Future<List<RecentSession>> recentSessions({int limit = 5}) async {
    final rows = await _local.recent(limit);
    return [
      for (final r in rows)
        RecentSession(
          collectionId: r.subjectId,
          lastIndex: r.lastIndex,
          updatedAtMs: r.updatedAtMs,
        ),
    ];
  }

  @override
  Stream<List<RecentSession>> watchRecentSessions({int limit = 5}) {
    return _local
        .watchRecent(limit)
        .map(
          (rows) => [
            for (final r in rows)
              RecentSession(
                collectionId: r.subjectId,
                lastIndex: r.lastIndex,
                updatedAtMs: r.updatedAtMs,
              ),
          ],
        );
  }
}
