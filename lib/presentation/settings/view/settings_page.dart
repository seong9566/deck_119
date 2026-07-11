import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/app_theme_mode.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../theme_mode_mapper.dart';
import '../viewmodel/settings_view_model.dart';

/// 설정(DESIGN_HANDOFF §2.2). 하단 탭 IA의 세 번째 탭.
/// 테마 라디오 + 앱 정보(버전·오픈소스 라이선스). 문의하기 없음(§3-3).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final mode =
        ref.watch(settingsControllerProvider).valueOrNull ?? AppThemeMode.system;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.huge),
          children: [
            Text('설정', style: AppText.titleScreen.copyWith(color: c.textPrimary)),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('테마'),
            const SizedBox(height: AppSpacing.sm + 2),
            ThemeRadioGroup(
              value: mode.material,
              onChanged: (tm) =>
                  ref.read(settingsControllerProvider.notifier).setMode(tm.app),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _SectionLabel('앱 정보'),
            const SizedBox(height: AppSpacing.sm + 2),
            _InfoCard(
              children: [
                const _InfoRow(label: '버전', value: '1.0.0'),
                _InfoRow(
                  label: '오픈소스 라이선스',
                  trailing: Icon(Icons.chevron_right, color: c.textTertiary),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: '119덱',
                    applicationVersion: '1.0.0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Text('119덱 · 소방관계법규',
                  style: AppText.caption.copyWith(color: c.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(text,
          style: AppText.label.copyWith(
              color: context.colors.textTertiary, letterSpacing: 0.3)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: appCardRadius,
        border: Border.all(color: c.outline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: c.outline),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _InfoRow({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppText.choice.copyWith(color: c.textPrimary)),
            ),
            if (value != null)
              Text(value!,
                  style: AppText.caption.copyWith(color: c.textTertiary)),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
