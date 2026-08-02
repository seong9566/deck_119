import '../entities/ai_quiz_set.dart';
import '../repositories/ai_answer_repository.dart';
import '../repositories/generated_question_repository.dart';

/// AI 문제함 세트 구성 — 누적 문항(생성순)에 기존 응답을 얹는다.
class GetAiQuizSet {
  final GeneratedQuestionRepository _generated;
  final AiAnswerRepository _answers;

  GetAiQuizSet(this._generated, this._answers);

  Future<AiQuizSet> call(String subjectId) async {
    final questions = await _generated.getAll(subjectId);
    if (questions.isEmpty) return AiQuizSet.empty;
    final selections = await _answers.selections(subjectId);
    return AiQuizSet(
      questions: questions,
      answers: [for (final q in questions) selections[q.id]],
    );
  }
}
