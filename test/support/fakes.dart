import 'package:deck_119/domain/entities/app_theme_mode.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/domain/entities/subject.dart';
import 'package:deck_119/domain/repositories/progress_repository.dart';
import 'package:deck_119/domain/repositories/question_repository.dart';
import 'package:deck_119/domain/repositories/session_repository.dart';
import 'package:deck_119/domain/repositories/settings_repository.dart';

/// 테스트용 고정 콘텐츠 저장소.
class FakeQuestionRepository implements QuestionRepository {
  final List<Question> questions;
  const FakeQuestionRepository(this.questions);

  @override
  Future<List<Subject>> getSubjects() async =>
      const [Subject(id: 's1', name: '테스트과목')];

  @override
  Future<List<Question>> getQuestions(String subjectId) async => questions;
}

/// 테스트용 인메모리 진척 저장소.
class FakeProgressRepository implements ProgressRepository {
  final Set<String> wrong = {};

  @override
  Future<void> recordAttempt(String questionId, {required bool correct}) async {
    if (correct) {
      wrong.remove(questionId);
    } else {
      wrong.add(questionId);
    }
  }

  @override
  Future<Set<String>> getWrongIds() async => {...wrong};

  @override
  Future<void> clearWrong(String questionId) async => wrong.remove(questionId);
}

/// 테스트용 인메모리 이어풀기 저장소.
class FakeSessionRepository implements SessionRepository {
  final Map<String, int> _last = {};

  @override
  Future<int?> getLastIndex(String subjectId) async => _last[subjectId];

  @override
  Future<void> save(String subjectId, int lastIndex) async =>
      _last[subjectId] = lastIndex;

  @override
  Future<void> clear(String subjectId) async => _last.remove(subjectId);
}

/// 테스트용 인메모리 설정 저장소.
class FakeSettingsRepository implements SettingsRepository {
  AppThemeMode mode;
  FakeSettingsRepository([this.mode = AppThemeMode.system]);

  @override
  Future<AppThemeMode> getThemeMode() async => mode;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async => this.mode = mode;
}

/// 3지문 샘플(모두 answerIndex 0). 테스트에서 정/오답을 명시적으로 조합.
Question q(String id, String stem, List<String> choices) => Question(
      id: id,
      subjectId: 's1',
      type: QuestionType.mcq,
      year: 2024,
      stem: stem,
      choices: choices,
      answerIndex: 0,
      explanation: '$id 해설',
      difficulty: 'v3',
      tags: const [],
    );
