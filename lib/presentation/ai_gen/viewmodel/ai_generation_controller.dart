import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di.dart';
import '../../../domain/repositories/ai_question_repository.dart';
import 'ai_gen_view_model.dart';

/// 진행 중인 생성 작업(홈 인디케이터 표시용).
class AiGenJob {
  final String docId;
  final AiGenOptions options;
  const AiGenJob({required this.docId, required this.options});
}

/// 앱 스코프 AI 생성 컨트롤러(autoDispose 아님 — 생성 페이지가 pop돼도 유지).
/// 상태 null=진행 없음, non-null=진행 1건. 동시 1건 제한.
final aiGenerationControllerProvider =
    NotifierProvider<AiGenerationController, AiGenJob?>(
  AiGenerationController.new,
);

class AiGenerationController extends Notifier<AiGenJob?> {
  StreamSubscription<AiGenOutcome>? _sub;
  bool _starting = false;

  @override
  AiGenJob? build() {
    ref.onDispose(() => _sub?.cancel());
    return null;
  }

  /// 생성 시작. 이미 진행 중이거나 제출 대기 중이면 false(호출측이 차단 스낵바).
  /// submit 실패는 예외 전파. `_starting`으로 submit await 중 재진입(중복 제출)을 막는다.
  Future<bool> start({
    required String subjectId,
    required AiGenOptions options,
  }) async {
    if (state != null || _starting) return false;
    _starting = true;
    try {
      final repo = ref.read(aiQuestionRepositoryProvider);
      final docId = await repo.submit(
        subjectId: subjectId,
        yearScope: options.yearScope,
        count: options.count,
        type: options.type,
      );
      state = AiGenJob(docId: docId, options: options);
      await _sub?.cancel();
      _sub = repo.watch(docId).listen(
        (outcome) => _onOutcome(docId, outcome),
        onError: (_) => _onStreamError(docId),
      );
      return true;
    } finally {
      _starting = false;
    }
  }

  Future<void> _onOutcome(String docId, AiGenOutcome outcome) async {
    final notify = ref.read(notificationServiceProvider);
    switch (outcome) {
      case AiGenDone(:final questions):
        if (questions.isNotEmpty) {
          await ref.read(generatedQuestionRepositoryProvider).save(questions);
          await notify.showDone(questions.length);
        } else {
          await notify.showError();
        }
      case AiGenError():
        await notify.showError();
    }
    await _cleanup(docId);
  }

  /// watch 스트림 자체가 에러(권한 거부·매핑 예외 등)면 진행 상태가 영구히 멈추지
  /// 않도록 오류 알림 후 작업을 정리한다.
  Future<void> _onStreamError(String docId) async {
    await ref.read(notificationServiceProvider).showError();
    await _cleanup(docId);
  }

  Future<void> _cleanup(String docId) async {
    await ref.read(aiQuestionRepositoryProvider).removePending(docId);
    await _sub?.cancel();
    _sub = null;
    state = null;
  }
}
