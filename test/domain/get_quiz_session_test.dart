import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/domain/usecases/get_question_set.dart';
import 'package:deck_119/domain/usecases/get_quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// 세션 복원 규칙: 저장된 출제 목록이 원천이고, 콘텐츠가 바뀌어 문항이 사라져도
/// 남은 문항의 답·위치가 어긋나지 않아야 한다.
void main() {
  final questions = [
    q('q1', 'Q1 지문', ['A', 'B']),
    q('q2', 'Q2 지문', ['A', 'B']),
    q('q3', 'Q3 지문', ['A', 'B']),
  ];

  late FakeSessionRepository session;
  late GetQuizSession usecase;

  setUp(() {
    session = FakeSessionRepository();
    final content = FakeQuestionRepository(questions);
    final progress = FakeProgressRepository();
    usecase = GetQuizSession(
      content,
      GetQuestionSet(content, progress),
      session,
    );
  });

  test('resume=false면 세션을 무시하고 새 세트로 시작한다', () async {
    await session.save('s1', QuizMode.normal,
        lastIndex: 2, answers: [0, 1, null], questionIds: ['q1', 'q2', 'q3']);

    final data = await usecase('s1', QuizMode.normal, resume: false);
    expect(data.startIndex, 0);
    expect(data.answers, [null, null, null]);
  });

  test('저장된 출제 목록의 순서·답·위치를 그대로 복원한다', () async {
    await session.save('s1', QuizMode.random,
        lastIndex: 1, answers: [0, 1, null], questionIds: ['q3', 'q1', 'q2']);

    final data = await usecase('s1', QuizMode.random, resume: true);
    expect(data.questions.map((e) => e.id).toList(), ['q3', 'q1', 'q2']);
    expect(data.answers, [0, 1, null]);
    expect(data.startIndex, 1);
  });

  test('사라진 문항은 건너뛰고 남은 답·위치를 보정한다', () async {
    // q9는 더 이상 콘텐츠에 없다(첫 자리) → 뒤 문항들이 한 칸씩 앞당겨진다.
    await session.save('s1', QuizMode.review,
        lastIndex: 2,
        answers: [0, 1, 0, null],
        questionIds: ['q9', 'q1', 'q2', 'q3']);

    final data = await usecase('s1', QuizMode.review, resume: true);
    expect(data.questions.map((e) => e.id).toList(), ['q1', 'q2', 'q3']);
    expect(data.answers, [1, 0, null], reason: '사라진 문항의 답도 함께 빠진다');
    expect(data.startIndex, 1, reason: '원래 3번째(q2)가 이제 2번째');
  });

  test('출제 목록의 문항이 모두 사라졌으면 세션을 버리고 새 세트로 시작한다', () async {
    await session.save('s1', QuizMode.normal,
        lastIndex: 1, answers: [0, 1], questionIds: ['gone-1', 'gone-2']);

    final data = await usecase('s1', QuizMode.normal, resume: true);
    expect(data.questions.map((e) => e.id).toList(), ['q1', 'q2', 'q3']);
    expect(data.answers, [null, null, null]);
    expect(data.startIndex, 0);
  });

  test('출제 목록이 없는 구 세션은 저장소 순서로 복원한다', () async {
    await session.save('s1', QuizMode.normal,
        lastIndex: 2, answers: [0, 1, null], questionIds: const []);

    final data = await usecase('s1', QuizMode.normal, resume: true);
    expect(data.questions.map((e) => e.id).toList(), ['q1', 'q2', 'q3']);
    expect(data.answers, [0, 1, null]);
    expect(data.startIndex, 2);
  });
}
