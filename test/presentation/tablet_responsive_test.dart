import 'package:deck_119/di.dart';
import 'package:deck_119/domain/entities/quiz_mode.dart';
import 'package:deck_119/presentation/quiz/view/quiz_page.dart';
import 'package:deck_119/presentation/shared/theme/app_spacing.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:deck_119/presentation/shared/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// T18 태블릿 반응형 파운데이션 검증.
/// - [ResponsiveBody]가 폰에서는 전체 폭, 태블릿에서는 maxWidth로 제한하는지
/// - [ResponsiveContext] 임계값(shortestSide 기준)이 정확한지
/// - 풀이 화면이 태블릿 세로/가로에서 오버플로 없이 렌더되고 가독폭이 제한되는지
void main() {
  void setSurface(WidgetTester tester, Size logicalSize) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = logicalSize; // dpr=1 → 논리=물리
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('ResponsiveBody', () {
    // 자식은 가로로 greedy한 위젯(실제 사용처의 ListView와 동일)이어야
    // ResponsiveBody의 maxWidth가 관측된다.
    Widget host() => const MaterialApp(
          home: ResponsiveBody(
            maxWidth: 720,
            child: SizedBox(key: Key('child'), height: 10, width: double.infinity),
          ),
        );

    testWidgets('폰 폭(<maxWidth)에서는 자식이 전체 폭을 차지', (tester) async {
      setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(host());
      expect(tester.getSize(find.byKey(const Key('child'))).width, 390);
    });

    testWidgets('태블릿 폭(>maxWidth)에서는 maxWidth로 제한', (tester) async {
      setSurface(tester, const Size(1194, 834));
      await tester.pumpWidget(host());
      expect(tester.getSize(find.byKey(const Key('child'))).width, 720);
    });
  });

  group('ResponsiveContext 임계값', () {
    late bool tablet;
    late bool expanded;
    Widget probe() => MaterialApp(
          home: Builder(builder: (ctx) {
            tablet = ctx.isTablet;
            expanded = ctx.isExpanded;
            return const SizedBox();
          }),
        );

    testWidgets('폰 세로(shortest 390): 태블릿 아님', (tester) async {
      setSurface(tester, const Size(390, 844));
      await tester.pumpWidget(probe());
      expect(tablet, isFalse);
      expect(expanded, isFalse);
    });

    testWidgets('iPad(shortest 834): 태블릿, 대형 아님', (tester) async {
      setSurface(tester, const Size(834, 1194));
      await tester.pumpWidget(probe());
      expect(tablet, isTrue);
      expect(expanded, isFalse); // 834 < 840
    });

    testWidgets('iPad Pro(shortest 1024): 대형 태블릿', (tester) async {
      setSurface(tester, const Size(1024, 1366));
      await tester.pumpWidget(probe());
      expect(tablet, isTrue);
      expect(expanded, isTrue);
    });
  });

  group('풀이 화면 태블릿 무결', () {
    final questions = [
      q('q1', 'Q1 지문 내용', ['정답 선택지', '오답 선택지']),
      q('q2', 'Q2 지문 내용', ['정답 선택지', '오답 선택지']),
    ];
    Widget quizHost() => ProviderScope(
          overrides: [
            questionRepositoryProvider
                .overrideWithValue(FakeQuestionRepository(questions)),
            progressRepositoryProvider
                .overrideWithValue(FakeProgressRepository()),
            sessionRepositoryProvider
                .overrideWithValue(FakeSessionRepository()),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const QuizPage(categoryId: 's1', mode: QuizMode.normal),
          ),
        );

    // 콘텐츠는 readingMax(720)에서 좌우 패딩(xl*2)을 뺀 폭으로 제한된다.
    const expectedContentWidth = AppBreakpoints.readingMax - AppSpacing.xl * 2;

    for (final (name, size) in <(String, Size)>[
      ('세로', Size(834, 1194)),
      ('가로', Size(1194, 834)),
    ]) {
      testWidgets('iPad $name: 오버플로 없이 렌더 + 가독폭 제한', (tester) async {
        setSurface(tester, size);
        await tester.pumpWidget(quizHost());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Q1 지문 내용'), findsOneWidget);

        // 문제 카드가 화면 전체로 늘어지지 않고 readingMax 안으로 제한되는지.
        final cardWidth = tester.getSize(find.byType(QuestionCard).first).width;
        expect(cardWidth, closeTo(expectedContentWidth, 0.5));
      });
    }
  });
}
