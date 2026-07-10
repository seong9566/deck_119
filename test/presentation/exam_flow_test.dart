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

  Future<FakeProgressRepository> pumpExam(WidgetTester tester) async {
    final progress = FakeProgressRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(FakeQuestionRepository(questions)),
          progressRepositoryProvider.overrideWithValue(progress),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const QuizPage(subjectId: 's1', mode: QuizMode.exam),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return progress;
  }

  testWidgets('시험 모드: 응답 → 제출 → 점수·오답 리뷰', (tester) async {
    final progress = await pumpExam(tester);

    // Q1: 즉시채점이 숨겨져 해설 배너가 없다.
    expect(find.text('Q1 지문'), findsOneWidget);
    expect(find.text('해설'), findsNothing);

    // Q1 정답 선택 → 다음
    await tester.tap(find.text('A1 옳음'));
    await tester.pumpAndSettle();
    expect(find.text('해설'), findsNothing); // 여전히 채점 숨김
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // Q2 오답 선택 → 다음
    await tester.tap(find.text('A2 틀림'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    // Q3 정답 선택 → 제출
    await tester.tap(find.text('A3 옳음'));
    await tester.pumpAndSettle();
    expect(find.text('제출'), findsOneWidget);
    await tester.tap(find.text('제출'));
    await tester.pumpAndSettle();

    // 결과: 2/3, 오답 리뷰에 Q2 노출(내 답/정답 포함)
    expect(find.text('2 / 3'), findsOneWidget);
    expect(find.text('오답 리뷰 (1)'), findsOneWidget);
    expect(find.text('Q2 지문'), findsOneWidget);
    expect(find.text('내 답  '), findsOneWidget);
    expect(find.text('정답  '), findsOneWidget);
    expect(find.text('A2 틀림'), findsOneWidget); // 내가 고른 오답
    expect(find.text('A2 옳음'), findsOneWidget); // 정답

    // 일괄 채점으로 오답이 저장됐다(q2).
    expect(await progress.getWrongIds(), {'q2'});
  });

  testWidgets('시험 모드: 미응답 문항은 오답으로 채점된다', (tester) async {
    final progress = await pumpExam(tester);

    // Q1만 정답, Q2·Q3 미응답으로 끝까지 진행 후 제출
    await tester.tap(find.text('A1 옳음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('제출'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 3'), findsOneWidget);
    expect(await progress.getWrongIds(), {'q2', 'q3'});
  });
}
