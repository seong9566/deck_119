import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/question.dart';
import '../../domain/repositories/ai_question_repository.dart';
import '../datasources/local/drift_pending_ai_data_source.dart';

/// Firestore 큐 중계로 AI 문제를 생성한다.
/// 앱은 요청 doc을 쓰고, 맥북 워커가 그걸 집어 CLI로 생성 후 결과를 doc에 기록한다.
/// 앱은 그 doc을 구독하다 status=done이면 [Question](source: ai)으로 매핑한다.
///
/// 타임아웃 안전망: 요청 doc id를 로컬([DriftPendingAiDataSource])에 기록해 두고,
/// 앱이 타임아웃으로 결과를 못 받아도 [recoverCompleted]로 나중에 회수한다.
class AiQuestionRepositoryImpl implements AiQuestionRepository {
  static const _collection = 'gen_requests';

  final FirebaseFirestore _db;
  final DriftPendingAiDataSource _pending;

  /// 워커(맥북)가 꺼져 있거나 지연될 때의 대기 상한.
  final Duration timeout;

  AiQuestionRepositoryImpl(
    this._db,
    this._pending, {
    this.timeout = const Duration(seconds: 90),
  });

  @override
  Future<List<Question>> generate({
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
    // 회수 안전망: 요청을 로컬에 기록(타임아웃돼도 나중에 회수).
    await _pending.add(doc.id,
        subjectId: subjectId,
        yearScope: yearScope,
        nowMs: DateTime.now().millisecondsSinceEpoch);

    try {
      final snap = await doc
          .snapshots()
          .firstWhere((s) {
            final st = s.data()?['status'];
            return st == 'done' || st == 'error';
          })
          .timeout(timeout);

      final data = snap.data()!;
      if (data['status'] == 'error') {
        await _pending.remove(doc.id); // 실패는 회수 대상 아님
        throw AiGenException(data['error'] as String? ?? '생성에 실패했어요.');
      }

      final questions =
          _mapQuestions(data, docId: doc.id, subjectId: subjectId, yearScope: yearScope);
      await _pending.remove(doc.id); // 정상 수신 → 대기목록에서 제거
      return questions;
    } on TimeoutException {
      // 대기목록에 남긴다 → 홈 진입 시 recoverCompleted가 회수.
      throw AiGenException('생성이 오래 걸려요. 완료되면 홈 "AI 문제함"에 담겨요.');
    } on AiGenException {
      rethrow;
    } catch (e) {
      throw AiGenException('생성에 실패했어요. 잠시 후 다시 시도해 주세요.');
    }
  }

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
