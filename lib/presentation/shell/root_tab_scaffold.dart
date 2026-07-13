import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/theme/app_colors.dart';
import '../shared/theme/app_spacing.dart';

/// 하단 탭바 IA(DESIGN_HANDOFF §2.1). 홈·과목·설정 3탭 ShellRoute의 셸.
/// 탭바는 이 3화면에서만 표시(풀이·시험·결과는 풀스크린).
class RootTabScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;
  const RootTabScaffold({super.key, required this.shell});

  static const _tabs = <(IconData, String)>[
    (Icons.home_outlined, '홈'),
    (Icons.layers_outlined, '과목'),
    (Icons.tune, '설정'),
  ];

  void _onTap(int i) {
    // 같은 탭 재탭 시 해당 브랜치 초기 라우트로 복귀.
    shell.goBranch(i, initialLocation: i == shell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm + 2),
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  _TabItem(
                    icon: _tabs[i].$1,
                    label: _tabs[i].$2,
                    active: i == shell.currentIndex,
                    onTap: () => _onTap(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = active ? c.brand : c.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: AppSpacing.xs - 1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
