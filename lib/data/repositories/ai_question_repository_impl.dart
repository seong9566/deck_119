import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/question.dart';
import '../../domain/repositories/ai_question_repository.dart';

/// Firestore 큐 중계로 AI 문제를 생성한다.
/// 앱은 요청 doc을 쓰고, 맥북 워커가 그걸 집어 CLI로 생성 후 결과를 doc에 기록한다.
/// 앱은 그 doc을 구독하다 status=done이면 [Question](source: ai)으로 매핑한다.
class AiQuestionRepositoryImpl implements AiQuestionRepository {
  static const _collection = 'gen_requests';

  final FirebaseFirestore _db;

  /// 워커(맥북)가 꺼져 있거나 지연될 때의 대기 상한.
  final Duration timeout;

  AiQuestionRepositoryImpl(this._db, {this.timeout = const Duration(seconds: 90)});

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
        throw AiGenException(data['error'] as String? ?? '생성에 실패했어요.');
      }

      final rawList = (data['questions'] as List?) ?? const [];
      final year = int.tryParse(yearScope); // "all" → null
      final now = DateTime.now().microsecondsSinceEpoch;
      return [
        for (var i = 0; i < rawList.length; i++)
          _toQuestion(
            Map<String, dynamic>.from(rawList[i] as Map),
            subjectId: subjectId,
            year: year,
            id: 'ai-$now-$i',
          ),
      ];
    } on TimeoutException {
      throw AiGenException('생성기가 응답하지 않아요(맥북 확인). 잠시 후 다시 시도해 주세요.');
    } on AiGenException {
      rethrow;
    } catch (e) {
      throw AiGenException('생성에 실패했어요. 잠시 후 다시 시도해 주세요.');
    }
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
