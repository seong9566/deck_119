import 'package:deck_119/di.dart';
import 'package:deck_119/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  final questions = [
    q('q1', 'Q1 지문', ['A1 옳음', 'A1 틀림']),
    q('q2', 'Q2 지문', ['A2 옳음', 'A2 틀림']),
  ];

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(FakeQuestionRepository(questions)),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        ],
        child: const Deck119App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('홈 → 설정 아이콘 → /settings', (tester) async {
    await pumpApp(tester);
    expect(find.text('테스트과목'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('테마'), findsOneWidget); // 설정 화면 섹션 라벨
  });

  testWidgets('홈 → 전체 풀이 → /quiz', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('전체 풀이'));
    await tester.pumpAndSettle();

    expect(find.text('Q1 지문'), findsOneWidget);
  });

  testWidgets('홈 → 시험 모드 → /exam', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('시험 모드'));
    await tester.pumpAndSettle();

    // 시험은 제출 버튼(즉시채점 숨김) 흐름
    expect(find.text('Q1 지문'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });
}
