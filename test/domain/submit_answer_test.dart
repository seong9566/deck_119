import 'package:deck_119/domain/usecases/submit_answer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  test('submitAll: 여러 문항을 일괄 채점해 오답만 기록한다', () async {
    final progress = FakeProgressRepository();
    final usecase = SubmitAnswer(progress);

    // q()는 answerIndex 0 → 0은 정답, 그 외·미응답(-1)은 오답.
    await usecase.submitAll([
      (question: q('q1', 'Q1', ['옳음', '틀림']), selectedIndex: 0), // 정답
      (question: q('q2', 'Q2', ['옳음', '틀림']), selectedIndex: 1), // 오답
      (question: q('q3', 'Q3', ['옳음', '틀림']), selectedIndex: -1), // 미응답 → 오답
    ]);

    expect(progress.wrong, {'q2', 'q3'});
  });
}
