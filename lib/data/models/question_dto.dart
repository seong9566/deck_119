import '../../domain/entities/question.dart';

/// 저장 포맷(JSON) ↔ Domain 엔티티 매퍼. Data 모델을 Domain과 분리해
/// JSON 스키마 변화가 Domain·Presentation에 새지 않게 한다(클린 아키텍처 경계).
class QuestionDto {
  static Question fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subjectId: json['subjectId'] as String,
      type: (json['type'] as String) == 'ox' ? QuestionType.ox : QuestionType.mcq,
      year: json['year'] as int?,
      stem: json['stem'] as String,
      choices: (json['choices'] as List).cast<String>(),
      answerIndex: json['answerIndex'] as int,
      explanation: json['explanation'] as String,
      difficulty: (json['difficulty'] as String?) ?? 'v3',
      tags: (json['tags'] as List?)?.cast<String>() ?? const <String>[],
      breakdown: (json['breakdown'] as List?)
              ?.map((e) => _verdictFromJson(e as Map<String, dynamic>))
              .toList() ??
          const <StatementVerdict>[],
      // 번들 JSON엔 source가 없어 기본 bundled. AI 적립분만 'ai'로 복원된다.
      source: (json['source'] as String?) == 'ai'
          ? QuestionSource.ai
          : QuestionSource.bundled,
    );
  }

  /// Domain → 저장 JSON. AI 생성 문항 적립함(payload) 직렬화에 쓰인다.
  static Map<String, dynamic> toJson(Question q) {
    return {
      'id': q.id,
      'subjectId': q.subjectId,
      'type': q.type == QuestionType.ox ? 'ox' : 'mcq',
      'year': q.year,
      'stem': q.stem,
      'choices': q.choices,
      'answerIndex': q.answerIndex,
      'explanation': q.explanation,
      'difficulty': q.difficulty,
      'tags': q.tags,
      'breakdown': [
        for (final b in q.breakdown)
          {'label': b.label, 'correct': b.correct, 'note': b.note},
      ],
      'source': q.source == QuestionSource.ai ? 'ai' : 'bundled',
    };
  }

  static StatementVerdict _verdictFromJson(Map<String, dynamic> json) {
    return StatementVerdict(
      label: json['label'] as String,
      correct: json['correct'] as bool,
      note: (json['note'] as String?) ?? '',
    );
  }
}
