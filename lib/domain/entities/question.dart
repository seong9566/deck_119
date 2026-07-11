/// 문제 엔티티. 순수 Dart — Flutter·저장소를 모른다(클린 아키텍처 Domain).
enum QuestionType { mcq, ox }

/// 개수형(<보기> 중 옳은 개수) 문항의 보기별 판정. 해설을 보기 단위로
/// 쪼개 O/X와 교정을 보여주기 위한 데이터. label은 stem의 보기 기호(ㄱ·ㄴ…).
class StatementVerdict {
  final String label;

  /// 이 보기가 옳은지.
  final bool correct;

  /// 거짓일 때의 교정(옳으면 빈 문자열).
  final String note;

  const StatementVerdict({
    required this.label,
    required this.correct,
    this.note = '',
  });
}

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

  /// 개수형 보기별 판정(비어 있으면 일반 문항 → 해설은 단일 텍스트로 렌더).
  final List<StatementVerdict> breakdown;

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
    this.breakdown = const [],
  });

  bool isCorrect(int selectedIndex) => selectedIndex == answerIndex;
}
