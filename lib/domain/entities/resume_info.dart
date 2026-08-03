import 'quiz_mode.dart';

/// 이어풀기 정보. 어떤 모드의 세션인지와 마지막 위치·총 문항수.
class ResumeInfo {
  /// 어떤 모드로 풀던 세션인가(진입점 라벨·링크에 필요).
  final QuizMode mode;

  /// 마지막으로 머문 문항 인덱스(0-based).
  final int lastIndex;
  final int total;

  /// 문항별 선택 인덱스(길이 = 문항수, null = 미응답). 이어풀기 복원용.
  final List<int?> answers;

  const ResumeInfo({
    required this.mode,
    required this.lastIndex,
    required this.total,
    required this.answers,
  });

  /// 사람이 읽는 위치(1-based).
  int get position => lastIndex + 1;
}
