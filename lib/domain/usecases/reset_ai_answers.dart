import '../repositories/ai_answer_repository.dart';

/// AI 문제함 풀이 기록 초기화(처음부터 다시 풀기).
class ResetAiAnswers {
  final AiAnswerRepository _answers;
  ResetAiAnswers(this._answers);

  Future<void> call(String subjectId) => _answers.clearSubject(subjectId);
}
