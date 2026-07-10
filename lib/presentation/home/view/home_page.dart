import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/quiz_mode.dart';
import '../../../domain/entities/subject.dart';
import '../../quiz/view/quiz_page.dart';
import '../viewmodel/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(homeViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('119덱')),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패: $e')),
        data: (subjects) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final subject in subjects) _SubjectCard(subject: subject),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  const _SubjectCard({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(subject.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _ModeButton(subject: subject, mode: QuizMode.normal, label: '전체 풀이'),
            _ModeButton(subject: subject, mode: QuizMode.random, label: '랜덤'),
            _ModeButton(subject: subject, mode: QuizMode.review, label: '오답 재풀이'),
            _ModeButton(subject: subject, mode: QuizMode.exam, label: '시험 모드'),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final Subject subject;
  final QuizMode mode;
  final String label;
  const _ModeButton({
    required this.subject,
    required this.mode,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: FilledButton.tonal(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuizPage(subjectId: subject.id, mode: mode),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
