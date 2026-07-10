import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/home/view/home_page.dart';
import 'presentation/shared/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: Deck119App()));
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
