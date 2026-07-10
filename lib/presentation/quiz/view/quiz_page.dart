import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/question.dart';
import '../../../domain/entities/quiz_mode.dart';
import '../viewmodel/quiz_state.dart';
import '../viewmodel/quiz_view_model.dart';

class QuizPage extends ConsumerWidget {
  final String subjectId;
  final QuizMode mode;
  const QuizPage({super.key, required this.subjectId, required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (subjectId: subjectId, mode: mode);
    final async = ref.watch(quizViewModelProvider(args));

    return Scaffold(
      appBar: AppBar(title: Text(_modeTitle(mode))),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패: $e')),
        data: (state) {
          if (state.isEmpty) return const _EmptyView();
          if (state.finished) {
            return _ResultView(
              state: state,
              onRetry: () => ref.invalidate(quizViewModelProvider(args)),
            );
          }
          return _QuestionView(args: args, state: state);
        },
      ),
    );
  }
}

String _modeTitle(QuizMode mode) => switch (mode) {
      QuizMode.normal => '전체 풀이',
      QuizMode.random => '랜덤',
      QuizMode.review => '오답 재풀이',
      QuizMode.exam => '시험 모드',
    };

class _QuestionView extends ConsumerWidget {
  final QuizArgs args;
  final QuizState state;
  const _QuestionView({required this.args, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(quizViewModelProvider(args).notifier);
    final q = state.current;

    return Column(
      children: [
        LinearProgressIndicator(value: state.progress),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${state.position} / ${state.total}',
                  style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 8),
              Text(q.stem, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 20),
              for (var i = 0; i < q.choices.length; i++)
                _ChoiceTile(
                  label: q.choices[i],
                  status: _statusFor(i, q),
                  onTap: state.revealed ? null : () => vm.select(i),
                ),
              if (state.revealed) _ExplanationCard(question: q),
            ],
          ),
        ),
        if (state.revealed)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: vm.next,
                child: Text(state.isLast ? '결과 보기' : '다음'),
              ),
            ),
          ),
      ],
    );
  }

  _ChoiceStatus _statusFor(int i, Question q) {
    if (!state.revealed) return _ChoiceStatus.idle;
    if (i == q.answerIndex) return _ChoiceStatus.correct;
    if (i == state.selected) return _ChoiceStatus.wrong;
    return _ChoiceStatus.idle;
  }
}

enum _ChoiceStatus { idle, correct, wrong }

class _ChoiceTile extends StatelessWidget {
  final String label;
  final _ChoiceStatus status;
  final VoidCallback? onTap;
  const _ChoiceTile({
    required this.label,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      _ChoiceStatus.correct => (scheme.primaryContainer, scheme.onPrimaryContainer),
      _ChoiceStatus.wrong => (scheme.errorContainer, scheme.onErrorContainer),
      _ChoiceStatus.idle => (scheme.surfaceContainerHighest, scheme.onSurface),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(label, style: TextStyle(color: fg, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final Question question;
  const _ExplanationCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('해설', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(question.explanation),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final QuizState state;
  final VoidCallback onRetry;
  const _ResultView({required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('점수', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${state.correctCount} / ${state.total}',
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 24),
          FilledButton.tonal(onPressed: onRetry, child: const Text('다시 풀기')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('풀 문제가 없습니다.\n(오답 재풀이는 틀린 문제가 있을 때)'));
  }
}
