import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/domain/usecases/get_question_set.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// 모드별 세트 구성. 특히 quick(빠른 10문제)의 10문항 상한을 검증.
void main() {
  List<dynamic> mk(int n) => [for (var i = 0; i < n; i++) 'q$i'];

  GetQuestionSet make(int n) {
    final questions = [for (final id in mk(n)) q(id as String, '$id 지문', ['a', 'b'])];
    return GetQuestionSet(
      FakeQuestionRepository(questions),
      FakeProgressRepository(),
    );
  }

  test('quick: 25문항 중 10문항만 출제된다', () async {
    final set = await make(25)('s1', QuizMode.quick);
    expect(set.length, 10);
    // 원본에 있는 문항들로만 구성.
    expect(set.every((x) => x.id.startsWith('q')), isTrue);
    // 중복 없음.
    expect(set.map((x) => x.id).toSet().length, 10);
  });

  test('quick: 문항이 10개 미만이면 있는 만큼만', () async {
    final set = await make(4)('s1', QuizMode.quick);
    expect(set.length, 4);
  });

  test('random: 전체를 그대로(순서만 무작위) 반환', () async {
    final set = await make(25)('s1', QuizMode.random);
    expect(set.length, 25);
  });

  test('normal: 전체를 순서대로 반환', () async {
    final set = await make(12)('s1', QuizMode.normal);
    expect(set.length, 12);
    expect(set.first.id, 'q0');
  });
}
