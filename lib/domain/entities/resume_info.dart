/// 이어풀기 정보(normal 모드). 마지막 위치와 총 문항수.
class ResumeInfo {
  /// 마지막으로 머문 문항 인덱스(0-based).
  final int lastIndex;
  final int total;

  /// 문항별 선택 인덱스(길이 = 문항수, null = 미응답). 이어풀기 복원용.
  final List<int?> answers;

  const ResumeInfo({
    required this.lastIndex,
    required this.total,
    required this.answers,
  });

  /// 사람이 읽는 위치(1-based).
  int get position => lastIndex + 1;
}
