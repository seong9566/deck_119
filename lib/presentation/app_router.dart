import 'package:go_router/go_router.dart';

import '../domain/entities/quiz_mode.dart';
import 'home/view/home_page.dart';
import 'quiz/view/quiz_page.dart';
import 'settings/view/settings_page.dart';

/// 앱 라우트(BUILD_PLAN §3). 화면 5개를 go_router로 구성.
/// `/quiz`는 normal·random·review 공용(mode 쿼리), `/exam`은 시험 전용.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, _) => const HomePage(),
      ),
      GoRoute(
        path: Routes.quiz,
        builder: (_, state) {
          final p = state.uri.queryParameters;
          return QuizPage(
            subjectId: p['subjectId']!,
            mode: _parseMode(p['mode']),
            resume: p['resume'] == 'true',
          );
        },
      ),
      GoRoute(
        path: Routes.exam,
        builder: (_, state) => QuizPage(
          subjectId: state.uri.queryParameters['subjectId']!,
          mode: QuizMode.exam,
        ),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (_, _) => const SettingsPage(),
      ),
    ],
  );
}

QuizMode _parseMode(String? name) => QuizMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => QuizMode.normal,
    );

/// 라우트 경로·링크 빌더.
abstract final class Routes {
  static const home = '/';
  static const quiz = '/quiz';
  static const exam = '/exam';
  static const settings = '/settings';

  /// 풀이(normal·random·review) 링크.
  static String quizLink(String subjectId, QuizMode mode,
      {bool resume = false}) {
    final q = {
      'subjectId': subjectId,
      'mode': mode.name,
      if (resume) 'resume': 'true',
    };
    return Uri(path: quiz, queryParameters: q).toString();
  }

  /// 시험 링크.
  static String examLink(String subjectId) =>
      Uri(path: exam, queryParameters: {'subjectId': subjectId}).toString();
}
