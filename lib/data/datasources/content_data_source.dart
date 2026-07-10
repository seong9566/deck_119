import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/question.dart';
import '../../domain/entities/subject.dart';
import '../models/question_dto.dart';

/// 로드된 콘텐츠 번들(과목 + 문제).
class ContentBundle {
  final Subject subject;
  final List<Question> questions;

  const ContentBundle({required this.subject, required this.questions});
}

/// 앱 동봉 JSON 에셋에서 콘텐츠를 읽는다(읽기 전용, architecture §4.1).
/// MVP는 단일 과목 파일. 과목 확장 시 파일 목록을 순회하도록 확장.
class ContentDataSource {
  static const _assetPath = 'assets/content/fire-law.json';

  Future<ContentBundle> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final subjectJson = json['subject'] as Map<String, dynamic>;
    final subject = Subject(
      id: subjectJson['id'] as String,
      name: subjectJson['name'] as String,
    );

    final questions = (json['questions'] as List)
        .map((e) => QuestionDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return ContentBundle(subject: subject, questions: questions);
  }
}
