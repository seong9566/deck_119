import '../../domain/entities/progress_stats.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/local/drift_progress_data_source.dart';

/// 진척·오답 저장소 구현(Drift). 인터페이스 시그니처는 유지(Presentation 영향 0).
class ProgressRepositoryImpl implements ProgressRepository {
  final DriftProgressDataSource _local;

  ProgressRepositoryImpl(this._local);

  @override
  Future<void> recordAttempt(String questionId, {required bool correct}) {
    return _local.record(
      questionId,
      correct: correct,
      nowMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<Set<String>> getWrongIds() => _local.wrongIds();

  @override
  Future<void> clearWrong(String questionId) => _local.clear(questionId);

  @override
  Future<ProgressStats> getStats() async {
    final s = await _local.stats();
    return ProgressStats(
      attempts: s.attempts,
      correct: s.correct,
      distinctAttempted: s.distinct,
      streakDays: s.streak,
    );
  }
}
