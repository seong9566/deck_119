import '../entities/question.dart';
import '../entities/quiz_mode.dart';
import '../repositories/session_repository.dart';

/// 이어풀기 세션 저장 — 마지막 위치 + 문항별 선택 + 출제 목록.
/// 출제 목록까지 남겨야 random·quick·review를 같은 세트로 되살릴 수 있다.
class SaveSessionPosition {
  final SessionRepository _session;
  SaveSessionPosition(this._session);

  Future<void> call(
    String categoryId,
    QuizMode mode, {
    required int lastIndex,
    required List<int?> answers,
    required List<Question> questions,
  }) =>
      _session.save(
        categoryId,
        mode,
        lastIndex: lastIndex,
        answers: answers,
        questionIds: [for (final q in questions) q.id],
      );
}
