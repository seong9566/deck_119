import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/question.dart';
import '../../domain/repositories/ai_question_repository.dart';
import '../datasources/local/drift_pending_ai_data_source.dart';

/// Firestore 큐 중계로 AI 문제를 생성한다.
/// 앱은 요청 doc을 쓰고, 맥북 워커가 그걸 집어 CLI로 생성 후 결과를 doc에 기록한다.
/// 앱은 그 doc을 구독하다 status=done이면 [Question](source: ai)으로 매핑한다.
///
/// 회수 안전망: 요청 doc id를 로컬([DriftPendingAiDataSource])에 기록해 두고,
/// 앱이 결과를 못 받아도 [recoverCompleted]로 나중에 회수한다.
class AiQuestionRepositoryImpl implements AiQuestionRepository {
  static const _collection = 'gen_requests';

  final FirebaseFirestore _db;
  final DriftPendingAiDataSource _pending;

  AiQuestionRepositoryImpl(this._db, this._pending);

  @override
  Future<String> submit({
    required String subjectId,
    required String yearScope,
    required int count,
    required String type,
  }) async {
    final doc = _db.collection(_collection).doc();
    await doc.set({
      'subjectId': subjectId,
      'yearScope': yearScope,
      'count': count,
      'type': type,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    // 회수 안전망: 요청을 로컬에 기록(앱이 종료돼도 나중에 회수).
    await _pending.add(doc.id,
        subjectId: subjectId,
        yearScope: yearScope,
        nowMs: DateTime.now().millisecondsSinceEpoch);
    return doc.id;
  }

  @override
  Stream<AiGenOutcome> watch(String docId) {
    return _db.collection(_collection).doc(docId).snapshots().where((s) {
      final st = s.data()?['status'];
      return st == 'done' || st == 'error';
    }).map((s) {
      final data = s.data()!;
      if (data['status'] == 'error') {
        return AiGenError(data['error'] as String? ?? '생성에 실패했어요.');
      }
      final questions = _mapQuestions(
        data,
        docId: docId,
        subjectId: data['subjectId'] as String? ?? '',
        yearScope: data['yearScope'] as String? ?? 'all',
      );
      return AiGenDone(questions);
    });
  }

  @override
  Future<void> removePending(String docId) => _pending.remove(docId);

  @override
  Future<List<Question>> recoverCompleted() async {
    final pendings = await _pending.getAll();
    final recovered = <Question>[];
    for (final p in pendings) {
      try {
        final snap = await _db.collection(_collection).doc(p.docId).get();
        final data = snap.data();
        final status = data?['status'];
        if (data == null || status == 'error') {
          await _pending.remove(p.docId); // 폐기
        } else if (status == 'done') {
          recovered.addAll(_mapQuestions(data,
              docId: p.docId, subjectId: p.subjectId, yearScope: p.yearScope));
          await _pending.remove(p.docId);
        }
        // pending/processing → 유지(다음 기회에 회수)
      } catch (_) {
        // 조회 실패는 유지 → 다음 진입에서 재시도
      }
    }
    return recovered;
  }

  /// done doc의 questions[] → [Question] 리스트. id는 docId 기반이라 회수 중복이 없다.
  List<Question> _mapQuestions(
    Map<String, dynamic> data, {
    required String docId,
    required String subjectId,
    required String yearScope,
  }) {
    final rawList = (data['questions'] as List?) ?? const [];
    final year = int.tryParse(yearScope); // "all" → null
    return [
      for (var i = 0; i < rawList.length; i++)
        _toQuestion(
          Map<String, dynamic>.from(rawList[i] as Map),
          subjectId: subjectId,
          year: year,
          id: 'ai-$docId-$i',
        ),
    ];
  }

  Question _toQuestion(
    Map<String, dynamic> j, {
    required String subjectId,
    required int? year,
    required String id,
  }) {
    return Question(
      id: id,
      subjectId: subjectId,
      type: (j['type'] as String?) == 'ox' ? QuestionType.ox : QuestionType.mcq,
      year: year,
      stem: j['stem'] as String? ?? '',
      choices: ((j['choices'] as List?) ?? const []).cast<String>(),
      answerIndex: (j['answerIndex'] as num?)?.toInt() ?? 0,
      explanation: j['explanation'] as String? ?? '',
      difficulty: 'ai',
      tags: ((j['tags'] as List?) ?? const []).cast<String>(),
      breakdown: ((j['breakdown'] as List?) ?? const [])
          .map((e) => _verdict(Map<String, dynamic>.from(e as Map)))
          .toList(),
      source: QuestionSource.ai,
    );
  }

  StatementVerdict _verdict(Map<String, dynamic> j) => StatementVerdict(
        label: j['label'] as String? ?? '',
        correct: j['correct'] as bool? ?? false,
        note: j['note'] as String? ?? '',
      );
}
