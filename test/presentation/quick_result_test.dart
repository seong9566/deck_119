import 'package:deck_119/di.dart';
import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/presentation/quiz/view/quiz_page.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// 빠른 10문제(quick) 결과 화면의 재도전 버튼 라벨은 '다시 10문제'.
void main() {
  final questions = [
    q('q1', 'Q1 지문', ['A1 옳음', 'A1 틀림']),
    q('q2', 'Q2 지문', ['A2 옳음', 'A2 틀림']),
  ];

  Widget host(QuizMode mode) => ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(FakeQuestionRepository(questions)),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: QuizPage(categoryId: 's1', mode: mode),
        ),
      );

  // quick/random은 순서를 셔플하므로 특정 문항이 아니라
  // 현재 화면에 보이는 선택지('…옳음')를 탭한다(문항당 1개만 노출).
  Future<void> finishTwo(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('결과 보기'));
    await tester.pumpAndSettle();
  }

  testWidgets('quick 결과: 재도전 버튼이 "다시 10문제"', (tester) async {
    await tester.pumpWidget(host(QuizMode.quick));
    await finishTwo(tester);

    expect(find.text('채점 결과'), findsOneWidget);
    expect(find.text('다시 10문제'), findsOneWidget);
    expect(find.text('다시 풀기'), findsNothing);
  });

  testWidgets('random 결과: 재도전 버튼은 그대로 "다시 풀기"', (tester) async {
    await tester.pumpWidget(host(QuizMode.random));
    await finishTwo(tester);

    expect(find.text('다시 풀기'), findsOneWidget);
    expect(find.text('다시 10문제'), findsNothing);
  });
}
