import 'package:flutter/widgets.dart';

/// 타이포 토큰(DESIGN_HANDOFF §1.3) — Pretendard 스케일 고정. 임의 크기 금지.
/// fontFamily는 ThemeData에서 'Pretendard'로 전역 지정되어 상속된다(여기선
/// 크기·굵기·행간·자간만). 색은 사용처에서 [AppColors]로 적용한다.
abstract final class AppText {
  /// 결과 점수 800/55/1.0.
  static const TextStyle score =
      TextStyle(fontSize: 55, fontWeight: FontWeight.w800, height: 1.0);

  /// 결과 점수 단위(" / 25") 700/27.
  static const TextStyle scoreUnit =
      TextStyle(fontSize: 27, fontWeight: FontWeight.w700);

  /// 화면 제목(설정·과목) 800/21.
  static const TextStyle titleScreen =
      TextStyle(fontSize: 21, fontWeight: FontWeight.w800);

  /// 홈 로고 800/25.
  static const TextStyle logo =
      TextStyle(fontSize: 25, fontWeight: FontWeight.w800);

  /// 홈 선택 과목명 800/21.
  static const TextStyle subjectName =
      TextStyle(fontSize: 21, fontWeight: FontWeight.w800);

  /// 문항 지문(핵심) 600/18/1.55/-0.01em.
  static const TextStyle stem = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.55,
    letterSpacing: -0.19,
  );

  /// 선택지 600/15.
  static const TextStyle choice =
      TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

  /// OX 큰 글자 700/45.
  static const TextStyle oxGlyph =
      TextStyle(fontSize: 45, fontWeight: FontWeight.w700);

  /// 해설·본문 400/14/1.7.
  static const TextStyle body =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.7);

  /// 라벨·배지·섹션헤더(labelStrong) 700/11/+0.06em.
  static const TextStyle label =
      TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.6);

  /// 하단 탭 라벨 500/10(활성 시 사용처에서 w700).
  static const TextStyle tab =
      TextStyle(fontSize: 10, fontWeight: FontWeight.w500);

  /// 보조 캡션 500/12.
  static const TextStyle caption =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}
