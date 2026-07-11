import '../../../domain/entities/question.dart';
import '../../../domain/entities/quiz_mode.dart';

/// 풀이 화면의 불변 상태. ViewModel이 보유하고 View가 구독한다.
///
/// 문항별 선택은 [answers]에 보관한다. normal 계열은 선택 즉시 채점([revealed]),
/// exam은 채점을 숨기고 마지막에 일괄 채점([finished]).
class QuizState {
  final List<Question> questions;
  final QuizMode mode;
  final int index;

  /// 문항별 선택 인덱스(길이 = questions.length, null = 미응답).
  final List<int?> answers;

  /// 세션 종료(결과 화면).
  final bool finished;

  const QuizState({
    required this.questions,
    required this.mode,
    required this.answers,
    this.index = 0,
    this.finished = false,
  });

  factory QuizState.initial(List<Question> questions, QuizMode mode) => QuizState(
        questions: questions,
        mode: mode,
        answers: List<int?>.filled(questions.length, null),
      );

  bool get isEmpty => questions.isEmpty;
  bool get isExam => mode == QuizMode.exam;
  Question get current => questions[index];

  /// 현재 문항의 선택(null = 미응답).
  int? get selected => answers[index];

  /// 즉시채점·해설 노출 여부 — 현재 문항이 이미 응답됐는가(normal 계열).
  /// exam은 마지막 일괄 채점이라 항상 false.
  bool get revealed => !isExam && answers[index] != null;

  /// 이전 문항으로 이동 가능한가(첫 문항이 아닐 때).
  bool get canGoPrev => index > 0;

  int get total => questions.length;
  int get position => index + 1;
  bool get isLast => index + 1 >= total;
  double get progress => total == 0 ? 0 : position / total;

  /// 정답 수(선택과 정답 인덱스 비교로 파생).
  int get correctCount {
    var n = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].answerIndex) n++;
    }
    return n;
  }

  /// 틀린(또는 미응답) 문항 인덱스 목록 — 결과 오답 리뷰용.
  List<int> get wrongIndexes => [
        for (var i = 0; i < questions.length; i++)
          if (answers[i] != questions[i].answerIndex) i,
      ];

  QuizState copyWith({
    int? index,
    List<int?>? answers,
    bool? finished,
  }) {
    return QuizState(
      questions: questions,
      mode: mode,
      index: index ?? this.index,
      answers: answers ?? this.answers,
      finished: finished ?? this.finished,
    );
  }
}
