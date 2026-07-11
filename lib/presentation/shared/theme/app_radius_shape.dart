import 'package:flutter/widgets.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// 자주 쓰는 모서리 헬퍼(토큰 재사용). 하드코딩 반복 방지.
final BorderRadius appMdRadius = BorderRadius.circular(AppRadius.md);
final BorderRadius appSmRadius = BorderRadius.circular(AppRadius.sm);
final BorderRadius appTileRadius = BorderRadius.circular(AppRadius.tile);
final BorderRadius appCardRadius = BorderRadius.circular(AppRadius.card);
final BorderRadius appPillRadius = BorderRadius.circular(AppRadius.pill);

/// tile 모서리 사각 테두리(버튼 shape 등).
final RoundedRectangleBorder appTileShape =
    RoundedRectangleBorder(borderRadius: appTileRadius);

/// 카드 미세 그림자(DESIGN_HANDOFF §1.4 shadow 토큰 — 0 1px 2px).
List<BoxShadow> appCardShadow(AppColors c) => [
      BoxShadow(color: c.shadow, blurRadius: 2, offset: const Offset(0, 1)),
    ];
