import 'package:isar/isar.dart';

part 'attempt_record.g.dart';

/// 시도 이력(진척) 컬렉션(BUILD_PLAN §2). 채점 때마다 append.
@collection
class AttemptRecord {
  Id id = Isar.autoIncrement;

  late String questionId;

  late bool isCorrect;

  /// 시도 시각(epoch ms).
  late int timestampMs;

  // 아래 필드는 ProgressRepository 인터페이스 경계(§2, 시그니처 불변)에서
  // 전달되지 않아 MVP에서는 null. 통계(Could)용 스키마 자리만 유지. (BUILD_LOG T2)
  String? subjectId;

  /// 선택한 선택지 인덱스(0-based).
  int? selectedIndex;

  /// 풀이 모드 문자열(QuizMode.name).
  String? mode;
}
