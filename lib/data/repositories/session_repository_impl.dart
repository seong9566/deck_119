import '../../domain/repositories/session_repository.dart';
import '../datasources/local/isar_session_data_source.dart';

class SessionRepositoryImpl implements SessionRepository {
  final IsarSessionDataSource _local;
  SessionRepositoryImpl(this._local);

  @override
  Future<int?> getLastIndex(String subjectId) => _local.lastIndex(subjectId);

  @override
  Future<void> save(String subjectId, int lastIndex) => _local.save(
        subjectId,
        lastIndex,
        nowMs: DateTime.now().millisecondsSinceEpoch,
      );

  @override
  Future<void> clear(String subjectId) => _local.clear(subjectId);
}
