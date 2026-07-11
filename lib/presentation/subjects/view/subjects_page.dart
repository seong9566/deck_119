import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/view/home_page.dart';
import '../../shared/theme/app_colors.dart';

/// 과목(문제집) 화면 — 하단 탭 IA의 두 번째 탭.
/// 홈과 동일한 문제 세트 목록(원형 회차별·심화·전체)을 보여준다.
class SubjectsPage extends ConsumerWidget {
  const SubjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.background,
      body: const SafeArea(child: CollectionsView()),
    );
  }
}
