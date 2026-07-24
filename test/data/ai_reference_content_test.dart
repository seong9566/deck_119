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
    expect(first.imageAsset, isNotNull);
    expect(first.source, QuestionSource.ai);
    expect(
      questions.every((question) => question.source == QuestionSource.ai),
      isTrue,
    );
  });
}
