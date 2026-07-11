import 'package:flutter/widgets.dart';

/// 간격 토큰(DESIGN_HANDOFF §1.4). 4의 배수. 화면 좌우 패딩 = 20(xl).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double huge = 32;

  /// 화면 좌우 패딩(xl = 20).
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: xl);
}

/// 모서리 토큰(DESIGN_HANDOFF §1.4).
abstract final class AppRadius {
  static const double badge = 8; // 배지 6~8
  static const double md = 12;
  static const double tile = 14; // 타일
  static const double card = 16; // 카드
  static const double lg = 16;
  static const double ox = 20; // OX 버튼
  static const double iconBadge = 28; // 아이콘 배지
  static const double pill = 999; // chip/full

  /// 하위호환 별칭(기존 참조 유지).
  static const double sm = badge;
}
