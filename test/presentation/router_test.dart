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

  // fake는 세트 하나(전체)만 제공. 과목 탭으로 이동해 전체 세트를 열어 모드로 진입한다.
  Future<void> openAllSet(WidgetTester tester) async {
    await tester.tap(find.text('과목'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('전체'));
    await tester.pumpAndSettle();
  }

  testWidgets('홈(대시보드) → 설정 탭 → /settings', (tester) async {
    await pumpApp(tester);
    expect(find.text('안녕하세요 👋'), findsOneWidget); // 홈 = 대시보드

    await tester.tap(find.text('설정'));
    await tester.pumpAndSettle();

    expect(find.text('테마'), findsOneWidget); // 설정 화면 섹션 라벨
  });

  testWidgets('홈 → 과목 탭 → 세트 목록(회차별/난이도별)', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('과목'));
    await tester.pumpAndSettle();

    // 과목 탭 = 과목 헤더 + 난이도별(전체) 세트.
    expect(find.text('테스트과목'), findsOneWidget); // 과목명
    expect(find.text('난이도별'), findsOneWidget);
    expect(find.text('전체'), findsOneWidget);
  });

  testWidgets('과목 → 전체 세트 → 전체 풀이 → /quiz', (tester) async {
    await pumpApp(tester);
    await openAllSet(tester);
    expect(find.text('선택한 문제집'), findsOneWidget);

    await tester.tap(find.text('전체 풀이'));
    await tester.pumpAndSettle();

    expect(find.text('Q1 지문'), findsOneWidget);
  });

  testWidgets('과목 → 전체 세트 → 시험 모드 → /exam', (tester) async {
    await pumpApp(tester);
    await openAllSet(tester);

    final examTile = find.text('시험 모드');
    await tester.ensureVisible(examTile);
    await tester.tap(examTile);
    await tester.pumpAndSettle();

    expect(find.text('Q1 지문'), findsOneWidget);
    expect(find.text('다음'), findsOneWidget);
  });
}
