/// 풀이 모드. 단일 풀이 뷰가 모드 파라미터만 바꿔 재사용한다(architecture §5).
enum QuizMode {
  /// 전체 순서대로
  normal,

  /// 무작위 출제
  random,

  /// 오답만 재풀이
  review,

  /// 시험(시간제한·일괄채점). TODO: 타이머·일괄채점 미구현 — 현재는 normal과 동일 루프.
  exam,
}
