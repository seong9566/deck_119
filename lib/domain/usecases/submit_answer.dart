import '../entities/question.dart';
import '../repositories/progress_repository.dart';

/// 답 채점 + 진척·오답 기록.
class SubmitAnswer {
  final ProgressRepository _progress;

  SubmitAnswer(this._progress);

  Future<bool> call(Question question, int selectedIndex) async {
    final correct = question.isCorrect(selectedIndex);
    await _progress.recordAttempt(question.id, correct: correct);
    return correct;
  }

  /// 여러 문항 일괄 채점·기록(시험 제출). 미응답은 selectedIndex=-1로 넘긴다.
  /// 단일 배치로 기록해 watch 재집계 폭주를 막고 채점을 원자적으로 만든다.
  Future<void> submitAll(
      List<({Question question, int selectedIndex})> entries) async {
    await _progress.recordAttempts([
      for (final e in entries)
        (
          questionId: e.question.id,
          correct: e.question.isCorrect(e.selectedIndex),
        ),
    ]);
  }
}
