import '../../domain/repositories/progress_repository.dart';
import '../datasources/local_progress_data_source.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final LocalProgressDataSource _local;

  ProgressRepositoryImpl(this._local);

  @override
  Future<void> recordAttempt(String questionId, {required bool correct}) async {
    _local.record(questionId, correct: correct);
  }

  @override
  Future<Set<String>> getWrongIds() async => _local.wrongIds();

  @override
  Future<void> clearWrong(String questionId) async => _local.clear(questionId);
}
