import 'package:flutter/material.dart';

import '../theme/app_radius_shape.dart';
import '../theme/app_typography.dart';

/// 주요 액션 버튼(UI_DESIGN_SYSTEM §5). FilledButton, 높이 52, radius md, brand.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: appMdShape,
        textStyle: AppText.choice,
      ),
      child: Text(label),
    );
  }
}

/// 보조 액션 버튼(UI_DESIGN_SYSTEM §5). 중립 outlined. "다시 풀기"·"홈으로".
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: appMdShape,
        textStyle: AppText.choice,
      ),
      child: Text(label),
    );
  }
}
