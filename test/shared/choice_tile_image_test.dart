import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:deck_119/presentation/shared/widgets/choice_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  testWidgets('imageAsset이 있으면 선택지를 이미지로 렌더한다', (tester) async {
    await tester.pumpWidget(
      host(
        const ChoiceTile(
          label: '①',
          status: ChoiceStatus.idle,
          imageAsset: 'assets/content/images/fire-law-2026-1-opt1.png',
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('imageAsset이 없으면 label 텍스트를 렌더한다', (tester) async {
    await tester.pumpWidget(
      host(
        const ChoiceTile(
          label: '보기 텍스트',
          status: ChoiceStatus.idle,
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.text('보기 텍스트'), findsOneWidget);
  });
}
