import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// 일관된 상단바(타이틀 w700·배경 surface·하단 1px outline)와 좌우 lg 패딩,
/// 하단 고정 액션(SafeArea)을 제공하는 공용 스캐폴드(UI_DESIGN_SYSTEM §5).
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  /// 하단 고정 영역(PrimaryButton 등). SafeArea + 좌우 lg 패딩이 적용된다.
  final Widget? bottomBar;

  /// 본문에 좌우 lg 패딩을 적용할지. 스크롤 리스트가 자체 패딩을 관리하면 false.
  final bool padBody;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomBar,
    this.padBody = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: c.outline),
        ),
      ),
      body: SafeArea(
        child: padBody ? Padding(padding: AppSpacing.screenH, child: body) : body,
      ),
      bottomNavigationBar: bottomBar == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                child: bottomBar,
              ),
            ),
    );
  }
}
