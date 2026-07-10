/// 문제 엔티티. 순수 Dart — Flutter·저장소를 모른다(클린 아키텍처 Domain).
enum QuestionType { mcq, ox }

class Question {
  final String id;
  final String subjectId;
  final QuestionType type;
  final int? year;
  final String stem;
  final List<String> choices;

  /// 정답 인덱스(0-based). mcq ①=0, ox O=0/X=1.
  final int answerIndex;
  final String explanation;
  final String difficulty;
  final List<String> tags;

  const Question({
    required this.id,
    required this.subjectId,
    required this.type,
    required this.year,
    required this.stem,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
    required this.difficulty,
    required this.tags,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == answerIndex;
}
