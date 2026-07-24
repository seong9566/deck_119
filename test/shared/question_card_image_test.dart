import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:deck_119/presentation/shared/widgets/question_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  testWidgets('imageAsset이 있으면 이미지를 렌더한다', (tester) async {
    await tester.pumpWidget(
      host(
        const QuestionCard(
          type: QuestionType.mcq,
          stem: '지문',
          imageAsset: 'assets/content/images/fire-law-2026-1.png',
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('imageAsset이 없으면 이미지를 렌더하지 않는다', (tester) async {
    await tester.pumpWidget(
      host(
        const QuestionCard(
          type: QuestionType.mcq,
          stem: '지문',
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
  });
}
