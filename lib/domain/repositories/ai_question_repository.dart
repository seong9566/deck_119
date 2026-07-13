import '../entities/question.dart';

/// AI 실시간 문제 생성 포트. 년도별 기출 그라운딩으로 문제를 생성한다.
/// 구현은 Firebase Functions 프록시를 호출(앱엔 API 키 없음).
abstract interface class AiQuestionRepository {
  /// [yearScope]: "2025" | "2026" | "all". [type]: "mcq" | "ox" | "mixed".
  /// 실패 시 [AiGenException]을 던진다.
  Future<List<Question>> generate({
    required String subjectId,
    required String yearScope,
    required int count,
    required String type,
  });
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
