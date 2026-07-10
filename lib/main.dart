import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/local/isar_service.dart';
import 'di.dart';
import 'presentation/home/view/home_page.dart';
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

class Deck119App extends StatelessWidget {
  const Deck119App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '119덱',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomePage(),
    );
  }
}
