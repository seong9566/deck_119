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

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode =
        ref.watch(settingsControllerProvider).valueOrNull ?? AppThemeMode.system;

    return AppScaffold(
      title: '설정',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        children: [
          const _SectionLabel('테마'),
          const SizedBox(height: AppSpacing.sm),
          ThemeRadioGroup(
            value: mode.material,
            onChanged: (tm) =>
                ref.read(settingsControllerProvider.notifier).setMode(tm.app),
          ),
          const SizedBox(height: AppSpacing.xl),
          const _SectionLabel('앱 정보'),
          const SizedBox(height: AppSpacing.sm),
          const _InfoTile(label: '앱 이름', value: '119덱'),
          const _InfoTile(label: '설명', value: '소방공채 심화·OX 문제'),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppText.label.copyWith(color: context.colors.textSecondary));
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: appMdRadius,
        border: Border.all(color: c.outline),
      ),
      child: Row(
        children: [
          Text(label, style: AppText.choice.copyWith(color: c.textPrimary)),
          const Spacer(),
          Text(value, style: AppText.body.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}
