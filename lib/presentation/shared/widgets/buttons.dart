import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_typography.dart';

/// 주요 액션 버튼(DESIGN_HANDOFF §2.2). brand 채움, 높이 52, radius tile,
/// 700/16, disabled 시 opacity .4.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: appTileShape,
        backgroundColor: c.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: c.brand.withValues(alpha: .4),
        disabledForegroundColor: Colors.white.withValues(alpha: .9),
        textStyle: AppText.choice.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}

/// 보조 액션 버튼(DESIGN_HANDOFF §2.2). surface + outlineStrong 1.5 경계, 700/16.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: appTileShape,
        backgroundColor: c.surface,
        foregroundColor: c.textPrimary,
        side: BorderSide(color: c.outlineStrong, width: 1.5),
        textStyle: AppText.choice.copyWith(fontWeight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
