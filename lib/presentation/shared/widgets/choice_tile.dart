import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius_shape.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 선택지 타일 상태(DESIGN_HANDOFF §2.2).
enum ChoiceStatus {
  /// 기본.
  idle,

  /// 시험모드 선택(중립 강조 sel).
  selected,

  /// 채점 후 정답.
  correct,

  /// 채점 후 내가 고른 오답.
  wrong,

  /// 채점 후 나머지(흐림).
  dimmed,
}

/// 선택지 타일 유형. mc=세로 리스트 타일 / ox=대형 2버튼.
enum ChoiceVariant { mc, ox }

/// 상태별 배경·경계·전경·투명도 토큰(목업 tileColors).
class _TileColors {
  final Color bg;
  final Color border;
  final Color fg;
  final double opacity;
  const _TileColors(this.bg, this.border, this.fg, this.opacity);

  factory _TileColors.of(AppColors c, ChoiceStatus s) => switch (s) {
        ChoiceStatus.idle => _TileColors(c.surface, c.outline, c.textPrimary, 1),
        ChoiceStatus.selected => _TileColors(c.selTint, c.sel, c.textPrimary, 1),
        ChoiceStatus.correct =>
          _TileColors(c.onCorrect, c.correct, c.correctInk, 1),
        ChoiceStatus.wrong => _TileColors(c.onWrong, c.wrong, c.wrongInk, 1),
        ChoiceStatus.dimmed =>
          _TileColors(c.surface, c.outline, c.textTertiary, .5),
      };
}

/// 선택지 타일(DESIGN_HANDOFF §2.2). 색 + 아이콘(✓/✕) 3중 신호.
/// onTap이 null이면 비활성(채점 후). [variant]로 MC/OX 레이아웃 전환.
class ChoiceTile extends StatelessWidget {
  final String label;
  final ChoiceStatus status;
  final ChoiceVariant variant;
  final VoidCallback? onTap;

  /// 그림형 선택지의 도표 에셋(null이면 label 텍스트로 렌더). MC 전용.
  final String? imageAsset;

  const ChoiceTile({
    super.key,
    required this.label,
    required this.status,
    this.variant = ChoiceVariant.mc,
    this.onTap,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = _TileColors.of(c, status);
    return variant == ChoiceVariant.ox
        ? _buildOx(c, t)
        : _buildMc(c, t);
  }

  Widget _buildMc(AppColors c, _TileColors t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Opacity(
        opacity: t.opacity,
        child: Material(
          color: t.bg,
          borderRadius: appTileRadius,
          child: InkWell(
            borderRadius: appTileRadius,
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: appTileRadius,
                border: Border.all(color: t.border, width: 1.5),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: 14),
                // 그림형: 인디케이터를 Stack 오버레이로 띄워 이미지 위치를 고정
                // (Row로 두면 채점 후 인디케이터 폭만큼 이미지가 밀림).
                child: imageAsset != null
                    ? Stack(
                        children: [
                          SizedBox(
                            height: 220,
                            width: double.infinity,
                            child:
                                Image.asset(imageAsset!, fit: BoxFit.contain),
                          ),
                          if (_mcIndicator(c) case final w?)
                            Positioned(top: 0, right: 0, child: w),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Text(label,
                                style: AppText.choice.copyWith(color: t.fg)),
                          ),
                          if (_mcIndicator(c) case final w?) ...[
                            const SizedBox(width: AppSpacing.md),
                            w,
                          ],
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _mcIndicator(AppColors c) => switch (status) {
        ChoiceStatus.correct =>
          _CircleBadge(bg: c.correct, icon: Icons.check),
        ChoiceStatus.wrong => _CircleBadge(bg: c.wrong, icon: Icons.close),
        ChoiceStatus.selected => _SelectDot(color: c.sel),
        _ => null,
      };

  Widget _buildOx(AppColors c, _TileColors t) {
    return Expanded(
      child: Opacity(
        opacity: t.opacity,
        child: Material(
          color: t.bg,
          borderRadius: BorderRadius.circular(AppRadius.ox),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.ox),
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.ox),
                border: Border.all(color: t.border, width: 2),
              ),
              child: Container(
                constraints: const BoxConstraints(minHeight: 132),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: AppText.oxGlyph.copyWith(color: t.fg)),
                    if (_oxLabel(c) case final w?) ...[
                      const SizedBox(height: AppSpacing.sm),
                      w,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _oxLabel(AppColors c) => switch (status) {
        ChoiceStatus.correct => _PopIn(
            child: Text('✓ 정답',
                style: AppText.label.copyWith(color: c.correctInk))),
        ChoiceStatus.wrong => _PopIn(
            child:
                Text('✕ 오답', style: AppText.label.copyWith(color: c.wrongInk))),
        ChoiceStatus.selected =>
          Text('선택함', style: AppText.label.copyWith(color: c.textSecondary)),
        _ => null,
      };
}

/// ✓/✕ 원형 배지(채점 시 pop 애니메이션).
class _CircleBadge extends StatelessWidget {
  final Color bg;
  final IconData icon;
  const _CircleBadge({required this.bg, required this.icon});

  @override
  Widget build(BuildContext context) {
    return _PopIn(
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}

/// 시험모드 선택 표시 도트(6px 링).
class _SelectDot extends StatelessWidget {
  final Color color;
  const _SelectDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 6),
      ),
    );
  }
}

/// 등장 시 스케일 pop(~260ms, DESIGN_HANDOFF §1.2).
class _PopIn extends StatelessWidget {
  final Widget child;
  const _PopIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (_, v, child) =>
          Transform.scale(scale: v.clamp(0, 1.1), child: child),
      child: child,
    );
  }
}
