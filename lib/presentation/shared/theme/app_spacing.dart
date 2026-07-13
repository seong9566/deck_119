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

/// 반응형 breakpoint·콘텐츠 폭 토큰(T18 태블릿 대응).
/// 기준 = MediaQuery `shortestSide`(최단변). 회전과 무관하게 기기 크기로 분기한다.
/// 폰 < [tablet] ≤ 태블릿 < [expanded] ≤ 대형 태블릿.
abstract final class AppBreakpoints {
  /// 태블릿 진입 최단변(dp). Material 권장 600.
  static const double tablet = 600;

  /// 대형 태블릿(iPad Pro 등) 최단변(dp).
  static const double expanded = 840;

  /// 읽기 중심 화면의 최대 콘텐츠 폭(풀이·시험·결과·모드 선택).
  /// 대화면에서 한 줄이 과도하게 길어지지 않도록 가독폭을 제한한다.
  static const double readingMax = 720;

  /// 다단 그리드 화면의 최대 콘텐츠 폭(홈·과목).
  static const double gridMax = 1000;
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
