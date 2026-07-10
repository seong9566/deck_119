import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 테마 선택 라디오 그룹(UI_DESIGN_SYSTEM §5). 시스템/라이트/다크.
class ThemeRadioGroup extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  const ThemeRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const _options = <(ThemeMode, String)>[
    (ThemeMode.system, '시스템 설정 따름'),
    (ThemeMode.light, '라이트'),
    (ThemeMode.dark, '다크'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: appMdRadius,
        border: Border.all(color: c.outline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _options.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: c.outline),
            _ThemeRadioRow(
              label: _options[i].$2,
              selected: value == _options[i].$1,
              onTap: () => onChanged(_options[i].$1),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThemeRadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeRadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? c.brand : c.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppText.choice.copyWith(color: c.textPrimary)),
          ],
        ),
      ),
    );
  }
}
