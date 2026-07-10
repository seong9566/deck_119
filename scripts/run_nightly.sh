#!/usr/bin/env bash
# 119덱 야간 무인 빌드 러너. (bypass 권한 전제)
# 매 반복은 fresh 헤드리스 세션 — git 히스토리 + PM 태스크 보드 + docs/BUILD_LOG.md 로 이어감.
# 사용: nohup bash scripts/run_nightly.sh > /dev/null 2>&1 &   (또는 tmux 안에서 실행)
set -uo pipefail
cd "$(dirname "$0")/.."

VAULT=/Users/ihyeonseong/Desktop/obsidian_workspace/personal_dev_wiki
LOG="nightly-$(date +%Y%m%d-%H%M).log"
MAX_ITERS=15   # 안전 상한

PROMPT='너는 이 저장소(deck_119)의 MVP를 완성하는 자율 빌더다.
1) 현재 상태 파악: `git log --oneline -20`, `git branch -a`, 그리고 PM 태스크 보드
   `bash '"$VAULT"'/.claude/scripts/task.sh ls --project 소방-기출앱`.
2) docs/BUILD_PLAN.md 실행 순서(T1 → T9 → T2 → T3 → T4 → T5 → T6 → T7 → T8)에서 아직 done이 아닌 첫 태스크를 골라라.
3) 그 태스크를 `feat/Tx-...` 브랜치에서 구현. 모든 화면은 docs/UI_DESIGN_SYSTEM.md 토큰·공용 컴포넌트만 사용(색/간격 하드코딩 금지). 콘텐츠 JSON 정답·해설 수정 금지. 허용목록 외 의존성 추가 금지.
4) `flutter analyze` 이슈 0 + 관련 테스트 통과를 확인한 뒤 `Closes: Tx` trailer로 커밋하고 main에 머지해라.
5) 막히거나 스킵한 것은 docs/BUILD_LOG.md에 정직히 기록해라(추측·미완도 그대로).
6) 모든 태스크가 done이고 최종 검증(flutter analyze 0, flutter test 전부 통과)이 끝났으면 마지막 줄에 정확히 "ALL DONE"만 출력해라.
한 번에 가능한 만큼 진행하되, 검증 없이 다음 태스크로 넘어가지 마라.'

for i in $(seq 1 "$MAX_ITERS"); do
  echo "===== 반복 $i · $(date) =====" | tee -a "$LOG"
  claude --permission-mode bypassPermissions -p "$PROMPT" 2>&1 | tee -a "$LOG"
  if tail -n 8 "$LOG" | grep -q "ALL DONE"; then
    echo "===== ALL DONE 감지 · 종료 ($(date)) =====" | tee -a "$LOG"
    break
  fi
  sleep 5
done
echo "러너 종료. 로그: $LOG" | tee -a "$LOG"
