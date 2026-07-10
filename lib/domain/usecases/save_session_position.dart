import '../repositories/session_repository.dart';

/// 이어풀기 위치 저장(normal next마다).
class SaveSessionPosition {
  final SessionRepository _session;
  SaveSessionPosition(this._session);

  Future<void> call(String subjectId, int lastIndex) =>
      _session.save(subjectId, lastIndex);
}
