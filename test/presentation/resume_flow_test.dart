import 'package:deck_119/di.dart';
import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/presentation/quiz/view/quiz_page.dart';
import 'package:deck_119/presentation/quiz/viewmodel/quiz_view_model.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  final questions = [
    q('q1', 'Q1 지문', ['A1 옳음', 'A1 틀림']),
    q('q2', 'Q2 지문', ['A2 옳음', 'A2 틀림']),
    q('q3', 'Q3 지문', ['A3 옳음', 'A3 틀림']),
  ];

  ProviderScope host({
    required FakeSessionRepository session,
    required bool resume,
    QuizMode mode = QuizMode.normal,
    FakeProgressRepository? progress,
  }) {
    return ProviderScope(
      overrides: [
        questionRepositoryProvider
            .overrideWithValue(FakeQuestionRepository(questions)),
        progressRepositoryProvider
            .overrideWithValue(progress ?? FakeProgressRepository()),
        sessionRepositoryProvider.overrideWithValue(session),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: QuizPage(categoryId: 's1', mode: mode, resume: resume),
      ),
    );
  }

  testWidgets('normal: 다음마다 세션 위치가 저장된다', (tester) async {
    final session = FakeSessionRepository();
    await tester.pumpWidget(host(session: session, resume: false));
    await tester.pumpAndSettle();

    // Q1 응답(즉시 채점) → 다음 → Q2로 이동, 세션 index=1 저장
    await tester.tap(find.text('A1 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('Q2 지문'), findsOneWidget);
    expect((await session.load('s1', QuizMode.normal))?.lastIndex, 1);
  });

  testWidgets('normal + resume: 저장된 위치부터 이어푼다', (tester) async {
    final session = FakeSessionRepository();
    await session.save('s1', QuizMode.normal,
        lastIndex: 2, answers: [0, 0, null], questionIds: const []); // Q3(index 2)부터

    await tester.pumpWidget(host(session: session, resume: true));
    await tester.pumpAndSettle();

    // 마지막 문항(Q3)에서 시작(진행헤더에 3/3 표시)
    expect(find.text('Q3 지문'), findsOneWidget);
    expect(find.textContaining('3 / 3'), findsOneWidget);
  });

  testWidgets('normal: 마지막 문항 완료 시 세션이 삭제된다', (tester) async {
    final session = FakeSessionRepository();
    await session.save('s1', QuizMode.normal,
        lastIndex: 2, answers: [0, 0, null], questionIds: const []);

    await tester.pumpWidget(host(session: session, resume: true));
    await tester.pumpAndSettle();

    // Q3 응답 → 결과 보기(finish) → 세션 삭제
    await tester.tap(find.text('A3 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    expect(await session.load('s1', QuizMode.normal), isNull);
  });

  testWidgets('normal: 답을 고른 즉시 세션에 반영된다(다음을 누르기 전에 나가도 남는다)',
      (tester) async {
    final session = FakeSessionRepository();
    await tester.pumpWidget(host(session: session, resume: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('A1 옳음'));
    await tester.pumpAndSettle();

    final snap = await session.load('s1', QuizMode.normal);
    expect(snap?.lastIndex, 0);
    expect(snap?.answers, [0, null, null]);
    expect(snap?.questionIds, ['q1', 'q2', 'q3'], reason: '출제 목록도 함께 저장된다');
  });

  testWidgets('random: 셔플된 세트가 같은 순서로 이어풀린다', (tester) async {
    final session = FakeSessionRepository();
    await tester.pumpWidget(
        host(session: session, resume: false, mode: QuizMode.random));
    await tester.pumpAndSettle();

    // 셔플 결과는 매번 다르므로 화면에 뜬 첫 문항을 그대로 읽어 기준으로 삼는다.
    await tester.tap(find.textContaining('옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    final saved = await session.load('s1', QuizMode.random);
    expect(saved?.lastIndex, 1);
    expect(saved?.questionIds, hasLength(3));
    final order = saved!.questionIds;
    final secondStem = '${order[1].toUpperCase()} 지문';

    // 이탈 후 재진입 — 저장된 순서 그대로, 2번째 문항부터.
    await tester.pumpWidget(
        host(session: session, resume: true, mode: QuizMode.random));
    await tester.pumpAndSettle();

    expect(find.text(secondStem), findsOneWidget);
    expect(find.textContaining('2 / 3'), findsOneWidget);
  });

  testWidgets('exam: 제출 전까지 임시저장되고 제출하면 세션이 삭제된다', (tester) async {
    final session = FakeSessionRepository();
    final progress = FakeProgressRepository();
    await tester.pumpWidget(host(
        session: session,
        resume: false,
        mode: QuizMode.exam,
        progress: progress));
    await tester.pumpAndSettle();

    // Q1 선택 → 다음 → Q2 선택. 채점은 숨겨져 있지만 세션에는 남는다.
    await tester.tap(find.text('A1 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A2 틀림'));
    await tester.pumpAndSettle();

    final snap = await session.load('s1', QuizMode.exam);
    expect(snap?.lastIndex, 1);
    expect(snap?.answers, [0, 1, null]);

    // 재진입 — 고른 답과 위치가 복원된다.
    await tester.pumpWidget(host(
        session: session, resume: true, mode: QuizMode.exam, progress: progress));
    await tester.pumpAndSettle();
    expect(find.text('Q2 지문'), findsOneWidget);
    expect(find.textContaining('2 / 3'), findsOneWidget);

    // 제출하면 세션이 사라진다.
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('제출하고 채점'));
    await tester.pumpAndSettle();

    expect(await session.load('s1', QuizMode.exam), isNull);
    expect(await progress.getWrongIds(), {'q2', 'q3'});
  });

  test('QuizArgs는 resume 값으로 구분된다(family 키)', () {
    const a = (categoryId: 's1', mode: QuizMode.normal, resume: false);
    const b = (categoryId: 's1', mode: QuizMode.normal, resume: true);
    expect(a == b, isFalse);
    expect(a, isA<QuizArgs>());
  });
}
