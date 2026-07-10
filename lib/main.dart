import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/local/isar_service.dart';
import 'di.dart';
import 'presentation/settings/theme_mode_mapper.dart';
import 'presentation/settings/viewmodel/settings_view_model.dart';
import 'presentation/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await IsarService.open();
  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const Deck119App(),
    ),
  );
}

class Deck119App extends ConsumerWidget {
  const Deck119App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 저장된 테마 모드에 MaterialApp.themeMode를 바인딩(로딩 중엔 system).
    final themeMode =
        ref.watch(settingsControllerProvider).valueOrNull?.material ??
            ThemeMode.system;

    return MaterialApp.router(
      title: '119덱',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
