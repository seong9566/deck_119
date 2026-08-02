import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../domain/entities/question.dart';
import '../../models/question_dto.dart';
import 'app_database.dart';

/// AI 생성 문항 적립함의 Drift 저장소. 문항 내용을 payload(JSON)로 보관해
/// 번들에 없는 합성 문항도 누적·복원한다.
class DriftGeneratedDataSource {
  final AppDatabase _db;
  DriftGeneratedDataSource(this._db);

  /// 생성분 append. 같은 id면 덮어씀(재저장 안전).
  Future<void> saveAll(List<Question> questions, {required int nowMs}) async {
    if (questions.isEmpty) return;
    await _db.batch((b) {
      for (final q in questions) {
        b.insert(
          _db.generatedQuestions,
          GeneratedQuestionsCompanion.insert(
            id: q.id,
            subjectId: q.subjectId,
            payload: jsonEncode(QuestionDto.toJson(q)),
            createdAtMs: nowMs,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// 누적 문항 생성순(createdAt asc, 동일 배치는 id asc).
  /// 나중에 만든 문항이 뒤에 쌓여야 이어풀기 위치가 밀리지 않는다.
  Future<List<Question>> getAll(String subjectId) async {
    final rows = await (_db.select(_db.generatedQuestions)
          ..where((t) => t.subjectId.equals(subjectId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAtMs, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.id, mode: OrderingMode.asc),
          ]))
        .get();
    return [
      for (final r in rows)
        QuestionDto.fromJson(jsonDecode(r.payload) as Map<String, dynamic>),
    ];
  }

  /// 누적 개수 실시간 구독(홈 카드 배지).
  Stream<int> watchCount(String subjectId) {
    final count = _db.generatedQuestions.id.count();
    final q = _db.selectOnly(_db.generatedQuestions)
      ..where(_db.generatedQuestions.subjectId.equals(subjectId))
      ..addColumns([count]);
    return q.map((row) => row.read(count) ?? 0).watchSingle();
  }
}
