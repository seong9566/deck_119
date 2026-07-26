import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_router.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_radius_shape.dart';
import '../../shared/theme/app_spacing.dart';
import '../../shared/theme/app_typography.dart';
import '../../shared/widgets/widgets.dart';
import '../viewmodel/ai_generation_controller.dart';

/// AI 문제 생성 옵션 화면. 년도(2025/2026/전체)·문항 수·유형 선택 → 백엔드 호출 →
/// 제출 후 홈으로 이동. AI 문항은 "참고용"(ADR-0002).
class AiGenPage extends ConsumerStatefulWidget {
  static const subjectId = 'fire-law';
  const AiGenPage({super.key});

  @override
  ConsumerState<AiGenPage> createState() => _AiGenPageState();
}

class _AiGenPageState extends ConsumerState<AiGenPage> {
  static const _count = 10; // 한 번에 10문항 고정
  String _year = 'all'; // "2025" | "2026" | "all" | "gichul-2026"(2026 소방공채 기출)
  String _type = 'mcq'; // "mcq" | "ox" | "mixed"

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _generate() async {
    try {
      final ok = await ref
          .read(aiGenerationControllerProvider.notifier)
          .start(
            subjectId: AiGenPage.subjectId,
            options: (yearScope: _year, count: _count, type: _type),
          );
      if (!mounted) return;
      if (ok) {
        _snack('생성 시작! 완료되면 알림드려요');
        _closeToHome(context);
      } else {
        _snack('이미 생성 중이에요. 완료되면 알려드려요.');
      }
    } catch (_) {
      if (mounted) _snack('생성 요청에 실패했어요. 잠시 후 다시 시도해 주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final busy = ref.watch(aiGenerationControllerProvider) != null;

    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.md, AppSpacing.xs),
              child: Row(
                children: [
                  Text('AI 문제 생성',
                      style: AppText.titleScreen.copyWith(color: c.textPrimary)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _closeToHome(context),
                    icon: const Icon(Icons.close),
                    color: c.textTertiary,
                    iconSize: 20,
                    tooltip: '닫기',
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxl),
                children: [
                  const _ReferenceNotice(),
                  const SizedBox(height: AppSpacing.xl),
                  _OptionGroup(
                    label: '년도',
                    options: const [
                      ('2025', '2025년'),
                      ('2026', '2026년'),
                      ('all', '전체'),
                    ],
                    selected: _year,
                    onSelect: (v) => setState(() => _year = v),
                    // 라벨이 길어 한 줄 폭에 안 맞는 기출 옵션은 아래 전체폭으로.
                    fullWidthOption: const ('gichul-2026', '2026 소방공채 기출문제'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _OptionGroup(
                    label: '유형',
                    options: const [
                      ('mcq', '객관식'),
                      ('ox', 'O/X'),
                      ('mixed', '혼합'),
                    ],
                    selected: _type,
                    onSelect: (v) => setState(() => _type = v),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(top: BorderSide(color: c.outline)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl,
                      AppSpacing.md - 2, AppSpacing.xl, AppSpacing.lg),
                  child: busy
                      ? _GeneratingButton(color: c.brand)
                      : PrimaryButton(label: 'AI로 10문제 만들기', onPressed: _generate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _closeToHome(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.home);
  }
}

/// 참고용 고지(ADR-0002 필수 안전장치).
class _ReferenceNotice extends StatelessWidget {
  const _ReferenceNotice();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: c.brandTint,
        border: Border.all(color: c.brand),
        borderRadius: appTileRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, size: 18, color: c.brandInk),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '년도별 기출을 바탕으로 AI가 새 문제를 만들어요.\nAI가 만든 문제이니 참고용으로만 활용하는 것을 권장해요.',
              style: AppText.caption.copyWith(color: c.brandInk, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// 라벨 + 선택 pill 그룹(단일 선택).
class _OptionGroup extends StatelessWidget {
  final String label;
  final List<(String, String)> options; // (value, label)
  final String selected;
  final ValueChanged<String> onSelect;

  /// 한 줄 폭에 안 맞는 긴 옵션(예: 기출) — 있으면 pill 행 아래 전체폭으로 추가.
  final (String, String)? fullWidthOption;
  const _OptionGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.fullWidthOption,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label.copyWith(color: c.textTertiary)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (final (value, text) in options) ...[
              Expanded(
                child: _Pill(
                  text: text,
                  selected: value == selected,
                  onTap: () => onSelect(value),
                ),
              ),
              if (value != options.last.$1)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        if (fullWidthOption case (final value, final text)) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: _Pill(
              text: text,
              selected: value == selected,
              onTap: () => onSelect(value),
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _Pill(
      {required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? c.brandTint : c.surface,
      borderRadius: appTileRadius,
      child: InkWell(
        borderRadius: appTileRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: appTileRadius,
            border: Border.all(
              color: selected ? c.brand : c.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: Text(
                text,
                style: AppText.choice.copyWith(
                  color: selected ? c.brandInk : c.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 생성 중 버튼(스피너 + 문구, 비활성).
class _GeneratingButton extends StatelessWidget {
  final Color color;
  const _GeneratingButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: null,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: appTileShape,
        disabledBackgroundColor: color.withValues(alpha: .5),
        disabledForegroundColor: Colors.white,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
          ),
          SizedBox(width: AppSpacing.sm),
          Text('문제를 만드는 중…'),
        ],
      ),
    );
  }
}
