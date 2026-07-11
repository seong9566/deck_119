import 'package:deck_119/di.dart';
import 'package:deck_119/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

void main() {
  testWidgets('앱이 뜨고 홈에 과목이 로드된다', (tester) async {
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
    expect(find.text('선택한 과목'), findsOneWidget);
    expect(find.text('소방관계법규'), findsOneWidget);
    // 문항 수는 하드코딩 아닌 실측(§3-1) — "총 N문항" 형태.
    expect(find.textContaining('문항'), findsWidgets);
    expect(find.text('풀이 모드'), findsOneWidget);
    for (final m in ['전체 풀이', '랜덤', '오답 재풀이', '시험 모드']) {
      expect(find.text(m), findsOneWidget);
    }
  });
}
