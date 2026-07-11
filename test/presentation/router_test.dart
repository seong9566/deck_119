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
    // 모드 타일이 세로로 쌓여 기본 뷰포트보다 길어질 수 있으므로 표면을 키운다.
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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

  testWidgets('홈 → 설정 탭 → /settings', (tester) async {
    await pumpApp(tester);
    expect(find.text('테스트과목'), findsOneWidget);

    // 하단 탭바의 설정 탭으로 이동.
    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();

    expect(find.text('테마'), findsOneWidget); // 설정 화면 섹션 라벨
  });

  testWidgets('홈 → 과목 탭 → /subjects', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('과목'));
    await tester.pumpAndSettle();

    expect(find.text('풀 과목을 선택하세요'), findsOneWidget);
  });

  testWidgets('홈 → 전체 풀이 → /quiz', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('전체 풀이'));
    await tester.pumpAndSettle();

    expect(find.text('Q1 지문'), findsOneWidget);
  });

  testWidgets('홈 → 시험 모드 → /exam', (tester) async {
    await pumpApp(tester);

    final examTile = find.text('시험 모드');
    await tester.ensureVisible(examTile);
    await tester.tap(examTile);
    await tester.pumpAndSettle();

    // 시험은 제출 버튼(즉시채점 숨김) 흐름
    expect(find.text('Q1 지문'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });
}
