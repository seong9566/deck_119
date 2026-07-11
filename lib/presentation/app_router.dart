import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/quiz_mode.dart';
import 'home/view/home_page.dart';
import 'home/view/set_mode_page.dart';
import 'quiz/view/quiz_page.dart';
import 'settings/view/settings_page.dart';
import 'shell/root_tab_scaffold.dart';
import 'subjects/view/subjects_page.dart';

/// 앱 라우트(DESIGN_HANDOFF §2.1). 하단 탭바 IA:
/// ShellRoute 3탭(홈·과목·설정, 탭바 표시) + 풀스크린 풀이·시험(탭바 없음).
GoRouter createRouter() {
  final shellKey = GlobalKey<NavigatorState>();
  return GoRouter(
    initialLocation: Routes.home,
    navigatorKey: shellKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => RootTabScaffold(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Routes.home, builder: (_, _) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: Routes.subjects,
                builder: (_, _) => const SubjectsPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: Routes.settings,
                builder: (_, _) => const SettingsPage()),
          ]),
        ],
      ),
      // 세트(문제집) 모드 선택 — 풀스크린 push.
      GoRoute(
        path: Routes.set,
        parentNavigatorKey: shellKey,
        builder: (_, state) {
          final p = state.uri.queryParameters;
          return SetModePage(
            collectionId: p['id']!,
            title: p['name'] ?? '문제집',
          );
        },
      ),
      // 풀스크린(탭바 없음) — 상위 네비게이터에 push.
      GoRoute(
        path: Routes.quiz,
        parentNavigatorKey: shellKey,
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
        parentNavigatorKey: shellKey,
        builder: (_, state) => QuizPage(
          subjectId: state.uri.queryParameters['subjectId']!,
          mode: QuizMode.exam,
        ),
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
  static const subjects = '/subjects';
  static const set = '/set';
  static const quiz = '/quiz';
  static const exam = '/exam';
  static const settings = '/settings';

  /// 세트(문제집) 모드 선택 링크.
  static String setLink(String collectionId, String name) =>
      Uri(path: set, queryParameters: {'id': collectionId, 'name': name})
          .toString();

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
