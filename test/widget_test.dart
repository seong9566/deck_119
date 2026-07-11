import 'package:deck_119/di.dart';
import 'package:deck_119/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('앱이 뜨고 홈에 학습 대시보드가 로드된다(세션 없음 → 시작 유도)', (tester) async {
    // 대시보드 전체(카드 여러 개)가 뷰포트에 들어오도록 표면을 크게 잡는다.
    await tester.binding.setSurfaceSize(const Size(600, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // 홈은 진척·이어풀기·오답 통계를 읽으므로 Isar 대신 fake 주입.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
          settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        ],
        child: const Deck119App(),
      ),
    );

    // 초기 로딩 스피너
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 실제 에셋 JSON(rootBundle) 로드는 실제 파일 I/O라 fake-async pump로는
    // 진행되지 않는다. runAsync 안에서만 완료되므로 여기서 로드를 마치게 한 뒤
    // pumpAndSettle로 반영한다.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // 홈 = 학습 대시보드.
    expect(find.text('안녕하세요 👋'), findsOneWidget);
    expect(find.text('오늘의 학습'), findsOneWidget);
    expect(find.text('빠른 10문제'), findsOneWidget);
    expect(find.text('오답 재풀이'), findsOneWidget);
    expect(find.text('내 진척'), findsOneWidget);
    expect(find.text('진행률'), findsOneWidget);
    // 세션이 없으므로 이어풀기 대신 시작 유도가 뜬다.
    expect(find.text('학습을 시작해 보세요'), findsOneWidget);
    expect(find.text('문제집 전체 보기 →'), findsOneWidget);
  });
}
