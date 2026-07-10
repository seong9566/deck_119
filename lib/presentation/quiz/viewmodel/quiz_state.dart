import '../../../domain/entities/question.dart';

/// 풀이 화면의 불변 상태. ViewModel이 보유하고 View가 구독한다.
class QuizState {
  final List<Question> questions;
  final int index;

  /// 현재 문항에서 고른 선택지 인덱스. null = 미응답.
  final int? selected;

  /// 채점·해설 노출 여부(응답 완료).
  final bool revealed;
  final int correctCount;
  final bool finished;

  const QuizState({
    required this.questions,
    this.index = 0,
    this.selected,
    this.revealed = false,
    this.correctCount = 0,
    this.finished = false,
  });

  factory QuizState.initial(List<Question> questions) =>
      QuizState(questions: questions);

  bool get isEmpty => questions.isEmpty;
  Question get current => questions[index];
  int get total => questions.length;
  int get position => index + 1;
  bool get isLast => index + 1 >= total;
  double get progress => total == 0 ? 0 : position / total;
}
