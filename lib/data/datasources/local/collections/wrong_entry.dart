import 'package:isar/isar.dart';

part 'wrong_entry.g.dart';

/// 오답 세트 컬렉션(BUILD_PLAN §2). 오답 발생 시 put, 정답 시 delete(즉시 제거).
@collection
class WrongEntry {
  Id id = Isar.autoIncrement;

  /// 문제 id — 오답 세트의 유일 키.
  @Index(unique: true, replace: true)
  late String questionId;

  /// 과목 id. ProgressRepository 인터페이스 경계에서 전달되지 않으면 null
  /// (MVP 오답 재풀이는 questionId만 사용 — BUILD_LOG T2 참고).
  String? subjectId;

  /// 오답 등록 시각(epoch ms).
  late int addedAtMs;
}
