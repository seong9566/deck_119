import 'package:deck_119/data/content/law_category_catalog.dart';
import 'package:deck_119/data/datasources/content_data_source.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadAiReference: 2026 기출 AI 참고 문항을 별도 로드', () async {
    final questions = await ContentDataSource().loadAiReference();

    expect(questions, hasLength(25));

    final first =
        questions.singleWhere((question) => question.id == 'fire-law-2026-1');
    expect(first.choiceImages, hasLength(4));
    expect(first.source, QuestionSource.ai);
    expect(
      questions.every((question) => question.source == QuestionSource.ai),
      isTrue,
    );
  });

  test('참고 세트 25문항이 법령별로 분류된다(참고 트랙 필터용)', () async {
    final questions = await ContentDataSource().loadAiReference();
    final counts = <String, int>{};
    for (final q in questions) {
      counts.update(classifyCategoryId(q), (v) => v + 1, ifAbsent: () => 1);
    }

    expect(questions, hasLength(25));
    expect(counts[catGibon], 3);
    expect(counts[catYebang], 5);
    expect(counts[catSisul], 6);
    expect(counts[catGongsa], 2);
    expect(counts[catWiheom], 4);
    expect(counts[catJosa], 2);
    expect(counts[catCross], 3);
    // 심화 OX·계산으로 새는 문항이 없어야 한다(모두 법령 분류됨).
    expect(counts[catSimhwaEtc] ?? 0, 0);
  });
}
