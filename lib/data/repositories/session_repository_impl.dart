import 'dart:async';

import '../../domain/entities/quiz_mode.dart';
import '../../domain/entities/recent_session.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/local/drift_session_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final DriftSessionDataSource _local;
  SessionRepositoryImpl(this._local);

  /// 저장된 mode 문자열 → 도메인 enum. 알 수 없는 값은 normal로 간주.
  static QuizMode _parseMode(String name) => QuizMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => QuizMode.normal,
      );

  @override
  Future<SessionSnapshot?> load(String categoryId, QuizMode mode) async {
    final snap = await _local.load(categoryId, mode.name);
    if (snap == null) return null;
    // 저장은 -1 sentinel, 도메인은 null 로 표현.
    return (
      lastIndex: snap.lastIndex,
      answers: [for (final a in snap.answers) a < 0 ? null : a],
      questionIds: snap.questionIds,
    );
  }

  @override
  Future<void> save(
    String categoryId,
    QuizMode mode, {
    required int lastIndex,
    required List<int?> answers,
    required List<String> questionIds,
  }) =>
      _local.save(
        categoryId,
        mode.name,
        lastIndex,
        [for (final a in answers) a ?? -1],
        questionIds,
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );

  @override
  Future<void> clear(String categoryId, QuizMode mode) =>
      _local.clear(categoryId, mode.name);

  @override
  Future<List<RecentSession>> recentSessions({
    int limit = 5,
    String? categoryId,
  }) async {
    final rows = await _local.recent(limit, categoryId: categoryId);
    return [for (final r in rows) _toDomain(r)];
  }

  @override
  Stream<List<RecentSession>> watchRecentSessions({int limit = 5}) {
    return _local
        .watchRecent(limit)
        .map((rows) => [for (final r in rows) _toDomain(r)]);
  }

  static RecentSession _toDomain(
          ({String subjectId, String mode, int lastIndex, int total, int updatedAtMs}) r) =>
      RecentSession(
        collectionId: r.subjectId,
        mode: _parseMode(r.mode),
        lastIndex: r.lastIndex,
        total: r.total,
        updatedAtMs: r.updatedAtMs,
      );
}
