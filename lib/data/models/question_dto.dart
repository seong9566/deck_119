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
    );
  }
}
