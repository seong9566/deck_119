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
  }) {
    return ProviderScope(
      overrides: [
        questionRepositoryProvider
            .overrideWithValue(FakeQuestionRepository(questions)),
        progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
        sessionRepositoryProvider.overrideWithValue(session),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        home: QuizPage(subjectId: 's1', mode: QuizMode.normal, resume: resume),
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
    expect(await session.getLastIndex('s1'), 1);
  });

  testWidgets('normal + resume: 저장된 위치부터 이어푼다', (tester) async {
    final session = FakeSessionRepository();
    await session.save('s1', 2); // Q3(index 2)부터

    await tester.pumpWidget(host(session: session, resume: true));
    await tester.pumpAndSettle();

    // 마지막 문항(Q3)에서 시작(진행헤더에 3/3 표시)
    expect(find.text('Q3 지문'), findsOneWidget);
    expect(find.text('3 / 3'), findsOneWidget);
  });

  testWidgets('normal: 마지막 문항 완료 시 세션이 삭제된다', (tester) async {
    final session = FakeSessionRepository();
    await session.save('s1', 2);

    await tester.pumpWidget(host(session: session, resume: true));
    await tester.pumpAndSettle();

    // Q3 응답 → 결과 보기(finish) → 세션 삭제
    await tester.tap(find.text('A3 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();

    expect(await session.getLastIndex('s1'), isNull);
  });

  test('QuizArgs는 resume 값으로 구분된다(family 키)', () {
    const a = (subjectId: 's1', mode: QuizMode.normal, resume: false);
    const b = (subjectId: 's1', mode: QuizMode.normal, resume: true);
    expect(a == b, isFalse);
    expect(a, isA<QuizArgs>());
  });
}
