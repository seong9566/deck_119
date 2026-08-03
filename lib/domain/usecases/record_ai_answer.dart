import '../entities/question.dart';
import '../repositories/ai_answer_repository.dart';

/// AI 문항 응답 기록. 통계·오답노트가 아니라 AI 전용 저장소에 남긴다.
class RecordAiAnswer {
  final AiAnswerRepository _answers;
  RecordAiAnswer(this._answers);

  Future<void> call(Question question, int selectedIndex) =>
      _answers.record(question, selectedIndex);
}
