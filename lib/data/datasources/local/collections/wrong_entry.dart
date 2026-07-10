import 'package:isar/isar.dart';

part 'wrong_entry.g.dart';

/// 오답 세트 컬렉션(BUILD_PLAN §2). 오답 발생 시 put, 정답 시 delete(즉시 제거).
@collection
class WrongEntry {
  Id id = Isar.autoIncrement;

  /// 문제 id — 오답 세트의 유일 키.
  @Index(unique: true, replace: true)
  late String questionId;

  late String subjectId;

  /// 오답 등록 시각(epoch ms).
  late int addedAtMs;
}
