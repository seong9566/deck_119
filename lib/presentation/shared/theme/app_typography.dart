import 'package:flutter/widgets.dart';

/// 타이포 토큰(DESIGN_HANDOFF §1.3) — Pretendard 스케일 고정. 임의 크기 금지.
/// fontFamily는 ThemeData에서 'Pretendard'로 전역 지정되어 상속된다(여기선
/// 크기·굵기·행간·자간만). 색은 사용처에서 [AppColors]로 적용한다.
abstract final class AppText {
  /// 결과 점수 800/56/1.0.
  static const TextStyle score =
      TextStyle(fontSize: 56, fontWeight: FontWeight.w800, height: 1.0);

  /// 결과 점수 단위(" / 25") 700/28.
  static const TextStyle scoreUnit =
      TextStyle(fontSize: 28, fontWeight: FontWeight.w700);

  /// 화면 제목(설정·과목) 800/22.
  static const TextStyle titleScreen =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w800);

  /// 홈 로고 800/26.
  static const TextStyle logo =
      TextStyle(fontSize: 26, fontWeight: FontWeight.w800);

  /// 홈 선택 과목명 800/22.
  static const TextStyle subjectName =
      TextStyle(fontSize: 22, fontWeight: FontWeight.w800);

  /// 문항 지문(핵심) 600/19/1.55/-0.01em.
  static const TextStyle stem = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w600,
    height: 1.55,
    letterSpacing: -0.19,
  );

  /// 선택지 600/16.
  static const TextStyle choice =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  /// OX 큰 글자 700/46.
  static const TextStyle oxGlyph =
      TextStyle(fontSize: 46, fontWeight: FontWeight.w700);

  /// 해설·본문 400/15/1.7.
  static const TextStyle body =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.7);

  /// 라벨·배지·섹션헤더(labelStrong) 700/12/+0.06em.
  static const TextStyle label =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6);

  /// 하단 탭 라벨 500/11(활성 시 사용처에서 w700).
  static const TextStyle tab =
      TextStyle(fontSize: 11, fontWeight: FontWeight.w500);

  /// 보조 캡션 500/13.
  static const TextStyle caption =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w500);
}
