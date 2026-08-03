import '../entities/quiz_mode.dart';
import '../repositories/session_repository.dart';

/// 이어풀기 세션 삭제(풀이 완료·시험 제출 시).
class ClearSession {
  final SessionRepository _session;
  ClearSession(this._session);

  Future<void> call(String categoryId, QuizMode mode) =>
      _session.clear(categoryId, mode);
}
