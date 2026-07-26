/// 문제 엔티티. 순수 Dart — Flutter·저장소를 모른다(클린 아키텍처 Domain).
enum QuestionType { mcq, ox }

/// 문항 출처. bundled=번들 검수 콘텐츠, ai=런타임 AI 생성(참고용).
enum QuestionSource { bundled, ai }

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

  /// 문항 도표/그림 에셋 경로(null이면 없음).
  final String? imageAsset;

  /// 선택지별 그림 에셋 경로(그림형 문항). choices와 같은 길이·순서.
  /// 비어 있으면 텍스트 선택지. 값이 있으면 해당 인덱스 선택지를 이미지로 렌더.
  final List<String> choiceImages;

  /// 개수형 보기별 판정(비어 있으면 일반 문항 → 해설은 단일 텍스트로 렌더).
  final List<StatementVerdict> breakdown;

  /// 문항 출처(기본 bundled). ai면 "참고용" 노출 대상.
  final QuestionSource source;

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
    this.imageAsset,
    this.choiceImages = const [],
    this.breakdown = const [],
    this.source = QuestionSource.bundled,
  });

  bool isCorrect(int selectedIndex) => selectedIndex == answerIndex;
}
