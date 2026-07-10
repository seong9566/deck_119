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

    // 에셋 JSON 로드 완료 후 과목·모드 노출
    await tester.pumpAndSettle();
    expect(find.text('소방관계법규'), findsOneWidget);
    expect(find.text('전체 풀이'), findsOneWidget);
  });
}
