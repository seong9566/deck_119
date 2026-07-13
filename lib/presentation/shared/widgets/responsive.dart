import 'package:flutter/widgets.dart';

import '../theme/app_spacing.dart';

/// 반응형 헬퍼(T18 태블릿 대응).
///
/// 화면 크기 분기는 [BuildContext.isTablet]/[BuildContext.isExpanded]로 읽고,
/// 대화면에서 콘텐츠가 좌우로 늘어지지 않도록 [ResponsiveBody]로 폭을 제한한다.
/// 분기 기준은 `MediaQuery.shortestSide`(최단변)라 세로/가로 회전과 무관하게
/// 같은 기기는 같은 레이아웃을 유지한다.
extension ResponsiveContext on BuildContext {
  /// 최단변(dp). 세로·가로 어느 방향이든 동일한 값.
  double get shortestSide => MediaQuery.sizeOf(this).shortestSide;

  /// 태블릿(최단변 ≥ 600dp) 이상 여부.
  bool get isTablet => shortestSide >= AppBreakpoints.tablet;

  /// 대형 태블릿(최단변 ≥ 840dp) 여부.
  bool get isExpanded => shortestSide >= AppBreakpoints.expanded;
}

/// 대화면에서 자식의 최대 폭을 제한하고 가운데 정렬하는 래퍼.
///
/// 폰(폭 < [maxWidth])에서는 `ConstrainedBox`가 그대로 전체 폭을 내주므로
/// 기존 레이아웃과 100% 동일하다. 태블릿에서만 [maxWidth]로 묶여 여백이 생긴다.
/// 각 화면의 스크롤 본문(ListView)·상단 헤더·하단 고정 바를 같은 [maxWidth]로
/// 감싸면 좌우 정렬이 일치한다.
class ResponsiveBody extends StatelessWidget {
  final Widget child;

  /// 최대 콘텐츠 폭. 읽기 화면 = [AppBreakpoints.readingMax],
  /// 그리드 화면 = [AppBreakpoints.gridMax].
  final double maxWidth;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.readingMax,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
