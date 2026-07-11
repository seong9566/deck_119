import 'package:deck_119/di.dart';
import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/presentation/quiz/view/quiz_page.dart';
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

  Widget examHost() => ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(FakeQuestionRepository(questions)),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const QuizPage(subjectId: 's1', mode: QuizMode.exam),
        ),
      );

  Widget normalHost(FakeSessionRepository session, {bool resume = false}) =>
      ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(FakeQuestionRepository(questions)),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(session),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home:
              QuizPage(subjectId: 's1', mode: QuizMode.normal, resume: resume),
        ),
      );

  testWidgets('첫 문항에서는 이전 버튼이 없다', (tester) async {
    await tester.pumpWidget(examHost());
    await tester.pumpAndSettle();

    expect(find.text('Q1 지문'), findsOneWidget);
    expect(find.text('이전'), findsNothing);
  });

  testWidgets('시험 모드: 이전으로 돌아가 답을 바꾸면 채점에 반영된다', (tester) async {
    await tester.pumpWidget(examHost());
    await tester.pumpAndSettle();

    // Q1 오답 선택 → 다음
    await tester.tap(find.text('A1 틀림'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // Q2에서 이전 버튼 노출 → 눌러 Q1로 복귀
    expect(find.text('Q2 지문'), findsOneWidget);
    expect(find.text('이전'), findsOneWidget);
    await tester.tap(find.text('이전'));
    await tester.pumpAndSettle();
    expect(find.text('Q1 지문'), findsOneWidget);

    // Q1 답을 정답으로 변경 후 끝까지 정답 → 3/3
    await tester.tap(find.text('A1 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A2 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A3 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('제출하고 채점'));
    await tester.pumpAndSettle();

    expect(find.text('3 / 3'), findsOneWidget);
  });

  testWidgets('normal: 이전으로 돌아가면 채점된 해설이 다시 보인다', (tester) async {
    await tester.pumpWidget(normalHost(FakeSessionRepository()));
    await tester.pumpAndSettle();

    // Q1 응답(즉시채점) → 해설 노출 → 다음 → Q2
    await tester.tap(find.text('A1 옳음'));
    await tester.pumpAndSettle();
    expect(find.text('해설'), findsOneWidget);
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.text('Q2 지문'), findsOneWidget);
    expect(find.text('해설'), findsNothing); // Q2는 아직 미응답

    // 이전 → Q1: 이미 채점된 상태(해설·정답 해설 텍스트) 복원
    await tester.tap(find.text('이전'));
    await tester.pumpAndSettle();
    expect(find.text('Q1 지문'), findsOneWidget);
    expect(find.text('해설'), findsOneWidget);
    expect(find.text('q1 해설'), findsOneWidget);
  });

  testWidgets('normal + resume: 이어푼 시작 위치보다 앞으로는 못 간다', (tester) async {
    final session = FakeSessionRepository();
    await session.save('s1', 2); // Q3(index 2)부터 이어풀기

    await tester.pumpWidget(normalHost(session, resume: true));
    await tester.pumpAndSettle();

    // 시작 문항(Q3)에서는 그 앞이 이번 세션 미응답이라 이전 버튼 없음
    expect(find.text('Q3 지문'), findsOneWidget);
    expect(find.text('이전'), findsNothing);
  });
}
