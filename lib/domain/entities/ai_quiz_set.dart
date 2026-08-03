import 'question.dart';

/// AI 문제함의 풀이 세트 — 누적 문항 + 지금까지의 응답을 합친 스냅샷.
/// 문항 집합이 계속 늘어나므로 진행 상태는 인덱스가 아니라 문항별 응답이 원천이다.
class AiQuizSet {
  /// 누적 문항(생성순).
  final List<Question> questions;

  /// 문항별 선택 인덱스(길이 = questions.length, null = 미풀이).
  final List<int?> answers;

  const AiQuizSet({required this.questions, required this.answers});

  static const empty = AiQuizSet(questions: [], answers: []);

  int get total => questions.length;
  int get solvedCount => answers.where((a) => a != null).length;
  int get unsolvedCount => total - solvedCount;
  bool get isEmpty => questions.isEmpty;

  /// 아직 풀지 않은 첫 문항(전부 풀었으면 0 — 처음부터 보여준다).
  int get firstUnsolvedIndex {
    final i = answers.indexWhere((a) => a == null);
    return i < 0 ? 0 : i;
  }

  /// 이어풀기/처음부터를 물어야 하는 상태(일부만 푼 경우).
  bool get isPartiallySolved => solvedCount > 0 && unsolvedCount > 0;

  /// 응답을 모두 지운 상태로(처음부터 다시 풀기).
  AiQuizSet get reset => AiQuizSet(
        questions: questions,
        answers: List<int?>.filled(questions.length, null),
      );
}
