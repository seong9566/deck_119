import 'package:deck_119/di.dart';
import 'package:deck_119/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

/// 반응형 회귀 방지: 다른 경로(과목 탭 등)에서 세션이 생기면
/// 앱 재시작·위젯 재생성 없이 홈 이어풀기가 즉시 나타나야 한다.
void main() {
  testWidgets('세션이 저장되면 홈 이어풀기가 재시작 없이 나타난다', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final session = FakeSessionRepository();
    final questions = [q('q1', 'Q1 지문', ['A', 'B'])];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(FakeQuestionRepository(questions)),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(session),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        ],
        child: const Deck119App(),
      ),
    );
    await tester.pumpAndSettle();

    // 초기: 세션 없음 → 시작 유도, 이어풀기 없음.
    expect(find.text('학습을 시작해 보세요'), findsOneWidget);
    expect(find.text('이어풀기'), findsNothing);

    // 다른 경로에서 세션 생성('전체' 세트 id 's1')을 시뮬레이션.
    await session.save('s1', 1, [0, null]);
    await tester.pumpAndSettle();

    // 재시작·위젯 재생성 없이 이어풀기가 반응형으로 나타난다.
    expect(find.text('이어풀기'), findsOneWidget);
    expect(find.text('학습을 시작해 보세요'), findsNothing);
  });
}
