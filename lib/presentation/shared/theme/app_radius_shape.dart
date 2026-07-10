import 'package:flutter/widgets.dart';

import 'app_spacing.dart';

/// 자주 쓰는 모서리 헬퍼(토큰 재사용). 하드코딩 반복 방지.
final BorderRadius appMdRadius = BorderRadius.circular(AppRadius.md);
final BorderRadius appSmRadius = BorderRadius.circular(AppRadius.sm);
final BorderRadius appPillRadius = BorderRadius.circular(AppRadius.pill);

/// md 모서리 사각 테두리(버튼 shape 등).
final RoundedRectangleBorder appMdShape =
    RoundedRectangleBorder(borderRadius: appMdRadius);
