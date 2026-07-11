import '../repositories/session_repository.dart';

/// 이어풀기 세션 저장(normal) — 마지막 위치 + 문항별 선택.
class SaveSessionPosition {
  final SessionRepository _session;
  SaveSessionPosition(this._session);

  Future<void> call(String subjectId, int lastIndex, List<int?> answers) =>
      _session.save(subjectId, lastIndex, answers);
}
