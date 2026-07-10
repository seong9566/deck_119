import 'package:flutter/widgets.dart';

/// 간격 토큰(UI_DESIGN_SYSTEM §4). 4의 배수. 화면 좌우 패딩 = lg.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// 화면 좌우 패딩(lg).
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: lg);
}

/// 모서리 토큰(UI_DESIGN_SYSTEM §4). 카드·타일·버튼 기본 md.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}
