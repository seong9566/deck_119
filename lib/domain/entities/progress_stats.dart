/// 대시보드 진척 통계(시도 로그 기반). AttemptRecord 집계 결과.
class ProgressStats {
  /// 총 시도 수(같은 문항 반복 포함).
  final int attempts;

  /// 정답 시도 수.
  final int correct;

  /// 한 번이라도 시도한 서로 다른 문항 수(진행바용).
  final int distinctAttempted;

  /// 연속 학습 일수(오늘 또는 어제부터 끊기지 않은 날 수).
  final int streakDays;

  const ProgressStats({
    required this.attempts,
    required this.correct,
    required this.distinctAttempted,
    required this.streakDays,
  });

  /// 정답률(0.0~1.0). 시도 없으면 null.
  double? get accuracy => attempts == 0 ? null : correct / attempts;

  static const empty = ProgressStats(
    attempts: 0,
    correct: 0,
    distinctAttempted: 0,
    streakDays: 0,
  );
}
