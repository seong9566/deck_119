import 'dart:async';

import 'package:deck_119/core/notifications/notification_service.dart';
import 'package:deck_119/domain/entities/app_theme_mode.dart';
import 'package:deck_119/domain/entities/progress_stats.dart';
import 'package:deck_119/domain/entities/question.dart';
import 'package:deck_119/domain/entities/question_category.dart';
import 'package:deck_119/domain/entities/recent_session.dart';
import 'package:deck_119/domain/entities/subject.dart';
import 'package:deck_119/domain/repositories/ai_question_repository.dart';
import 'package:deck_119/domain/repositories/generated_question_repository.dart';
import 'package:deck_119/domain/repositories/progress_repository.dart';
import 'package:deck_119/domain/repositories/question_repository.dart';
import 'package:deck_119/domain/repositories/session_repository.dart';
import 'package:deck_119/domain/repositories/settings_repository.dart';

/// 테스트용 AI 생성 저장소. doc별 결과 스트림을 테스트에서 직접 방출한다.
class FakeAiQuestionRepository implements AiQuestionRepository {
  final List<({String subjectId, String yearScope, int count, String type})>
      submitCalls = [];
  final List<String> removePendingCalls = [];
  final Map<String, StreamController<AiGenOutcome>> _controllers = {};
  var _nextDocId = 1;
  String? _latestDocId;

  @override
  Future<String> submit({
    required String subjectId,
    required String yearScope,
    required int count,
    required String type,
  }) async {
    submitCalls.add((
      subjectId: subjectId,
      yearScope: yearScope,
      count: count,
      type: type,
    ));
    final docId = 'doc-${_nextDocId++}';
    _latestDocId = docId;
    return docId;
  }

  @override
  Stream<AiGenOutcome> watch(String docId) => _controllers
      .putIfAbsent(docId, () => StreamController<AiGenOutcome>.broadcast())
      .stream;

  void emit(AiGenOutcome outcome) {
    final docId = _latestDocId;
    if (docId == null) throw StateError('submit을 먼저 호출해야 합니다.');
    _controllers[docId]!.add(outcome);
  }

  @override
  Future<void> removePending(String docId) async {
    removePendingCalls.add(docId);
  }

  @override
  Future<List<Question>> recoverCompleted() async => [];

  void dispose() {
    for (final controller in _controllers.values) {
      unawaited(controller.close());
    }
  }
}

class FakeNotificationService implements NotificationService {
  final List<int> doneCounts = [];
  var errorCount = 0;

  @override
  Future<void> init({void Function()? onTapHome}) async {}

  @override
  Future<void> showDone(int count) async {
    doneCounts.add(count);
  }

  @override
  Future<void> showError() async {
    errorCount++;
  }
}

/// 테스트용 인메모리 AI 문항 적립함.
class FakeGeneratedQuestionRepository implements GeneratedQuestionRepository {
  final List<Question> savedQuestions = [];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Future<void> save(List<Question> questions) async {
    savedQuestions.addAll(questions);
    if (_changes.hasListener) _changes.add(null);
  }

  @override
  Future<List<Question>> getAll(String subjectId) async =>
      savedQuestions.where((q) => q.subjectId == subjectId).toList();

  @override
  Stream<int> watchCount(String subjectId) async* {
    yield (await getAll(subjectId)).length;
    await for (final _ in _changes.stream) {
      yield (await getAll(subjectId)).length;
    }
  }

  void dispose() => unawaited(_changes.close());
}

/// 테스트용 고정 콘텐츠 저장소.
class FakeQuestionRepository implements QuestionRepository {
  final List<Question> questions;
  const FakeQuestionRepository(this.questions);

  @override
  Future<List<Subject>> getSubjects() async =>
      const [Subject(id: 's1', name: '테스트과목')];

  @override
  Future<List<QuestionCategory>> getCategories() async => [
        QuestionCategory(
            id: 's1::law:test', name: '테스트법', group: '법령', count: questions.length),
        QuestionCategory(
            id: 's1', name: '전체', group: '전체', count: questions.length),
      ];

  @override
  Future<List<Question>> getQuestions(String collectionId) async => questions;
}

/// 테스트용 인메모리 진척 저장소.
/// watch는 실제 drift처럼 현재 스냅샷을 먼저 방출한 뒤 변이마다 갱신을 흘린다.
class FakeProgressRepository implements ProgressRepository {
  final Set<String> wrong = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  void _notify() {
    if (_changes.hasListener) _changes.add(null);
  }

  @override
  Future<void> recordAttempt(String questionId, {required bool correct}) async {
    if (correct) {
      wrong.remove(questionId);
    } else {
      wrong.add(questionId);
    }
    _notify();
  }

  @override
  Future<void> recordAttempts(
      List<({String questionId, bool correct})> attempts) async {
    for (final a in attempts) {
      if (a.correct) {
        wrong.remove(a.questionId);
      } else {
        wrong.add(a.questionId);
      }
    }
    _notify();
  }

  @override
  Future<Set<String>> getWrongIds() async => {...wrong};

  @override
  Stream<Set<String>> watchWrongIds() async* {
    yield {...wrong};
    await for (final _ in _changes.stream) {
      yield {...wrong};
    }
  }

  @override
  Future<void> clearWrong(String questionId) async {
    wrong.remove(questionId);
    _notify();
  }

  @override
  Future<ProgressStats> getStats() async => ProgressStats(
        attempts: 0,
        correct: 0,
        distinctAttempted: 0,
        streakDays: 0,
      );

  @override
  Stream<ProgressStats> watchStats() async* {
    yield await getStats();
    await for (final _ in _changes.stream) {
      yield await getStats();
    }
  }
}

/// 테스트용 인메모리 이어풀기 저장소.
/// watch는 실제 drift처럼 현재 스냅샷을 먼저 방출한 뒤 변이마다 갱신을 흘린다.
class FakeSessionRepository implements SessionRepository {
  final Map<String, ({int lastIndex, List<int?> answers})> _sessions = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  void _notify() {
    if (_changes.hasListener) _changes.add(null);
  }

  @override
  Future<({int lastIndex, List<int?> answers})?> load(String subjectId) async =>
      _sessions[subjectId];

  @override
  Future<void> save(String subjectId, int lastIndex, List<int?> answers) async {
    _sessions[subjectId] = (lastIndex: lastIndex, answers: [...answers]);
    _notify();
  }

  @override
  Future<void> clear(String subjectId) async {
    _sessions.remove(subjectId);
    _notify();
  }

  @override
  Future<List<RecentSession>> recentSessions({int limit = 5}) async => [
        for (final e in _sessions.entries)
          RecentSession(
              collectionId: e.key, lastIndex: e.value.lastIndex, updatedAtMs: 0),
      ].take(limit).toList();

  @override
  Stream<List<RecentSession>> watchRecentSessions({int limit = 5}) async* {
    yield await recentSessions(limit: limit);
    await for (final _ in _changes.stream) {
      yield await recentSessions(limit: limit);
    }
  }
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
