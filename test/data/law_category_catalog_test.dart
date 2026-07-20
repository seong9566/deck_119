import 'dart:convert';
import 'dart:io';

import 'package:deck_119/data/content/law_category_catalog.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:flutter_test/flutter_test.dart';

Question _q(List<String> tags) => Question(
      id: 't',
      subjectId: 'fire-law',
      type: QuestionType.mcq,
      year: 2025,
      stem: 's',
      choices: const ['a', 'b'],
      answerIndex: 0,
      explanation: 'e',
      difficulty: 'v3',
      tags: tags,
    );

void main() {
  group('classifyCategoryId', () {
    test('법령 태그 → 해당 법령 카테고리', () {
      expect(classifyCategoryId(_q(['소방기본법'])), 'fire-law::law:gibon');
      expect(classifyCategoryId(_q(['위험물안전관리법'])), 'fire-law::law:wiheom');
    });

    test('소방시설법 이름 변형 4종 → 하나로 정규화', () {
      for (final t in [
        '소방시설 설치 및 관리에 관한 법률',
        '소방시설 설치 및 관리에 관한 법',
        '소방시설 설치 및 안전관리에 관한 법',
        '소방시설의 설치 및 관리에 관한 법률',
      ]) {
        expect(classifyCategoryId(_q([t])), 'fire-law::law:sisul');
      }
    });

    test('교차법령 태그 → 교차 카테고리', () {
      expect(classifyCategoryId(_q(['교차법령'])), 'fire-law::cross');
    });

    test('법령·교차 태그 없음 → 심화 OX·계산', () {
      expect(classifyCategoryId(_q(['OX', '경계'])), 'fire-law::simhwa-etc');
    });
  });

  test('실데이터 333문항 분류 카운트가 설계와 일치', () {
    final json = jsonDecode(File('assets/content/fire-law.json').readAsStringSync())
        as Map<String, dynamic>;
    final qs = (json['questions'] as List)
        .map((e) => Question(
              id: e['id'] as String,
              subjectId: e['subjectId'] as String,
              type: QuestionType.mcq,
              year: e['year'] as int?,
              stem: e['stem'] as String,
              choices: const ['a', 'b'],
              answerIndex: 0,
              explanation: '',
              difficulty: (e['difficulty'] ?? '') as String,
              tags: ((e['tags'] as List?) ?? const []).cast<String>(),
            ))
        .toList();

    final counts = <String, int>{};
    for (final q in qs) {
      counts.update(classifyCategoryId(q), (v) => v + 1, ifAbsent: () => 1);
    }

    expect(qs.length, 333);
    expect(counts['fire-law::law:gibon'], 46);
    expect(counts['fire-law::law:yebang'], 49);
    expect(counts['fire-law::law:sisul'], 71);
    expect(counts['fire-law::law:gongsa'], 50);
    expect(counts['fire-law::law:wiheom'], 53);
    expect(counts['fire-law::law:josa'], 7);
    expect(counts['fire-law::cross'], 39);
    expect(counts['fire-law::simhwa-etc'], 18);
  });

  test('기타 카테고리만 설명을 갖는다', () {
    expect(
      lawCategories.singleWhere((category) => category.id == catCross).description,
      '여러 법령을 묶은 문항',
    );
    expect(
      lawCategories
          .singleWhere((category) => category.id == catSimhwaEtc)
          .description,
      'OX·계산 등 심화 문항',
    );

    final lawDescriptions = lawCategories
        .where((category) => category.id != catCross && category.id != catSimhwaEtc)
        .map((category) => category.description);
    expect(lawDescriptions, hasLength(6));
    expect(lawDescriptions, everyElement(isNull));
  });
}
