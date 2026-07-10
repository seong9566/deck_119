import 'package:isar/isar.dart';

part 'attempt_record.g.dart';

/// 시도 이력(진척) 컬렉션(BUILD_PLAN §2). 채점 때마다 append.
@collection
class AttemptRecord {
  Id id = Isar.autoIncrement;

  late String questionId;
  late String subjectId;

  /// 선택한 선택지 인덱스(0-based).
  late int selectedIndex;

  late bool isCorrect;

  /// 풀이 모드 문자열(QuizMode.name).
  late String mode;

  /// 시도 시각(epoch ms).
  late int timestampMs;
}
