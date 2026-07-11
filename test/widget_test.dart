import 'package:deck_119/di.dart';
import 'package:deck_119/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('앱이 뜨고 홈에 문제 세트 목록이 로드되고, 세트 선택 시 모드가 뜬다', (tester) async {
    // 세트 목록(원형 11회+심화+전체 = 13행)이 기본 뷰포트보다 길어 하단 행이
    // lazy-build로 빠지므로 표면을 크게 잡는다.
    await tester.binding.setSurfaceSize(const Size(600, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    // 홈은 이어풀기 조회로 SessionRepository를 읽으므로 Isar 대신 fake 주입.
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
    // pumpAndSettle로 반영한다. (문항 수가 늘어 파일이 커져도 안전.)
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    // 홈 = 문제 세트 목록(원형 회차별·심화·전체).
    expect(find.text('소방관계법규'), findsOneWidget);
    expect(find.text('원형 · 동형모의고사'), findsOneWidget);
    expect(find.text('2026 1회'), findsWidgets);
    expect(find.text('심화 문제'), findsOneWidget);
    expect(find.text('전체'), findsOneWidget);
    // 문항 수는 하드코딩 아닌 실측(§3-1) — "N문항" 형태.
    expect(find.textContaining('문항'), findsWidgets);

    // 세트 선택 → 모드 화면.
    await tester.tap(find.text('전체'));
    await tester.pumpAndSettle();
    expect(find.text('선택한 문제집'), findsOneWidget);
    expect(find.text('풀이 모드'), findsOneWidget);
    for (final m in ['전체 풀이', '랜덤', '오답 재풀이', '시험 모드']) {
      expect(find.text(m), findsOneWidget);
    }
  });
}
