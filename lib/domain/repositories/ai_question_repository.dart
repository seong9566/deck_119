import '../entities/question.dart';

/// watch()가 방출하는 생성 결과.
sealed class AiGenOutcome {
  const AiGenOutcome();
}

class AiGenDone extends AiGenOutcome {
  final List<Question> questions;
  const AiGenDone(this.questions);
}

class AiGenError extends AiGenOutcome {
  final String message;
  const AiGenError(this.message);
}

/// AI 실시간 문제 생성 포트. 년도별 기출 그라운딩으로 문제를 생성한다.
/// 구현은 Firebase Functions 프록시를 호출(앱엔 API 키 없음).
abstract interface class AiQuestionRepository {
  /// [yearScope]: "2025" | "2026" | "all". [type]: "mcq" | "ox" | "mixed".
  /// 실패 시 [AiGenException]을 던진다.
  Future<String> submit({
    required String subjectId,
    required String yearScope,
    required int count,
    required String type,
  });

  /// 생성 결과를 구독한다. done/error만 방출하며 타임아웃은 두지 않는다.
  Stream<AiGenOutcome> watch(String docId);

  /// 처리 완료/실패한 요청을 로컬 대기목록에서 제거한다.
  Future<void> removePending(String docId);

  /// 회수 안전망: 앱이 못 받았던 대기 요청 중 done된 것을 매핑해 반환한다
  /// (대기목록에서 정리). 미완(pending/processing)은 유지, 실패는 폐기.
  /// 반환된 문항은 호출측이 적립함에 저장한다.
  Future<List<Question>> recoverCompleted();
}

/// 생성 실패(네트워크·한도 초과·서버 오류)를 UI가 구분해 표시하기 위한 예외.
class AiGenException implements Exception {
  final String message;

  /// 일일 한도 초과 여부(별도 문구 노출용).
  final bool rateLimited;
  const AiGenException(this.message, {this.rateLimited = false});

  @override
  String toString() => 'AiGenException($message)';
}
