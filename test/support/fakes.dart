import 'package:deck_119/domain/entities/app_theme_mode.dart';
import 'package:deck_119/domain/entities/progress_stats.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/domain/entities/question_collection.dart';
import 'package:deck_119/domain/entities/recent_session.dart';
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
  Future<List<QuestionCollection>> getCollections() async => [
        QuestionCollection(
            id: 's1', name: '전체', group: '전체', count: questions.length),
      ];

  @override
  Future<List<Question>> getQuestions(String collectionId) async => questions;
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

  @override
  Future<ProgressStats> getStats() async => ProgressStats(
        attempts: 0,
        correct: 0,
        distinctAttempted: 0,
        streakDays: 0,
      );
}

/// 테스트용 인메모리 이어풀기 저장소.
class FakeSessionRepository implements SessionRepository {
  final Map<String, ({int lastIndex, List<int?> answers})> _sessions = {};

  @override
  Future<({int lastIndex, List<int?> answers})?> load(String subjectId) async =>
      _sessions[subjectId];

  @override
  Future<void> save(String subjectId, int lastIndex, List<int?> answers) async =>
      _sessions[subjectId] = (lastIndex: lastIndex, answers: [...answers]);

  @override
  Future<void> clear(String subjectId) async => _sessions.remove(subjectId);

  @override
  Future<List<RecentSession>> recentSessions({int limit = 5}) async => [
        for (final e in _sessions.entries)
          RecentSession(
              collectionId: e.key, lastIndex: e.value.lastIndex, updatedAtMs: 0),
      ].take(limit).toList();
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
