import 'package:deck_119/di.dart';
import 'package:deck_119/domain/entities/app_theme_mode.dart';
import 'package:deck_119/main.dart';
import 'package:deck_119/presentation/settings/view/settings_page.dart';
import 'package:deck_119/presentation/settings/viewmodel/settings_view_model.dart';
import 'package:deck_119/presentation/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

void main() {
  testWidgets('설정: 다크 선택 → 저장소에 반영·상태 갱신', (tester) async {
    final settings = FakeSettingsRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
        child: MaterialApp(theme: AppTheme.light(), home: const SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('다크'));
    await tester.pumpAndSettle();

    expect(settings.mode, AppThemeMode.dark);
  });

  testWidgets('앱: 저장된 다크가 MaterialApp.themeMode에 반영된다', (tester) async {
    final settings = FakeSettingsRepository(AppThemeMode.dark);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(const FakeQuestionRepository([])),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: const Deck119App(),
      ),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('설정 변경이 앱 테마에 즉시 반영된다(라이트→다크)', (tester) async {
    final settings = FakeSettingsRepository(AppThemeMode.light);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          questionRepositoryProvider
              .overrideWithValue(const FakeQuestionRepository([])),
          progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
          sessionRepositoryProvider.overrideWithValue(FakeSessionRepository()),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
        child: const Deck119App(),
      ),
    );
    await tester.pumpAndSettle();

    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    await container
        .read(settingsControllerProvider.notifier)
        .setMode(AppThemeMode.dark);
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(settings.mode, AppThemeMode.dark);
  });
}
