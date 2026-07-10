import '../repositories/session_repository.dart';

/// 이어풀기 세션 삭제(normal finish 시).
class ClearSession {
  final SessionRepository _session;
  ClearSession(this._session);

  Future<void> call(String subjectId) => _session.clear(subjectId);
}
