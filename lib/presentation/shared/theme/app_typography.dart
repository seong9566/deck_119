import 'package:flutter/widgets.dart';

/// 타이포 토큰(UI_DESIGN_SYSTEM §3). 스케일 고정 — 임의 크기 금지.
/// 색은 사용처에서 [AppColors]로 적용한다(여기선 크기·굵기·행간만).
abstract final class AppText {
  /// 결과 점수 34/w700.
  static const TextStyle score =
      TextStyle(fontSize: 34, fontWeight: FontWeight.w700);

  /// 화면 제목 22/w700.
  static const TextStyle titleScreen =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w700);

  /// 문항 지문(핵심) 18/w600/1.5.
  static const TextStyle stem =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.5);

  /// 선택지 16/w500.
  static const TextStyle choice =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);

  /// 해설 본문 15/w400/1.6.
  static const TextStyle body =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.6);

  /// 라벨 12/w600/+0.5.
  static const TextStyle label =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);

  /// 보조 캡션 13/w400.
  static const TextStyle caption =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
}
