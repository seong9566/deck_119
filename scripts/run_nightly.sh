#!/usr/bin/env bash
# 119덱 야간 무인 빌드 러너. (bypass 권한 전제)
# 매 반복은 fresh 헤드리스 세션 — git 히스토리 + PM 태스크 보드 + docs/BUILD_LOG.md 로 이어감.
# 사용: nohup bash scripts/run_nightly.sh > /dev/null 2>&1 &   (또는 tmux 안에서 실행)
set -uo pipefail
cd "$(dirname "$0")/.."

VAULT=/Users/ihyeonseong/Desktop/obsidian_workspace/personal_dev_wiki
LOG="nightly-$(date +%Y%m%d-%H%M).log"
MAX_ITERS=15   # 안전 상한

PROMPT='너는 이 저장소(deck_119)의 디자인 반영(페이즈 2)을 완성하는 자율 빌더다. 기능은 이미 완주(T1~T9)했고, 이제 클로드 디자인 목업의 비주얼·IA를 실제 앱에 반영한다.
1) 현재 상태 파악: `git log --oneline -20`, `git branch -a`, 그리고 PM 태스크 보드
   `bash '"$VAULT"'/.claude/scripts/task.sh ls --project 소방-기출앱`.
2) docs/DESIGN_HANDOFF.md 실행 순서(T10 → T11 → T12 → T13 → T14 → T15 → T16)에서 아직 done이 아닌 첫 태스크를 골라라.
3) 그 태스크를 `feat/Tx-...` 브랜치에서 구현. 목업 docs/design/mockup.html을 Read로 대조(인라인 스타일·색·레이아웃)하며 만든다. 색/간격/타이포는 docs/DESIGN_HANDOFF.md §1 토큰만 사용(하드코딩 금지, 전부 shared/theme 경유). §3 스코프 가드 절대 준수: 실재 과목은 소방관계법규 1개뿐(목업의 4과목·진행률·done은 데모 더미이므로 하드코딩 금지) · 에러 카피는 오프라인 번들 앱에 맞게 · 문의하기 넣지 말 것(오픈소스 라이선스는 실제 구현) · 의존성 추가 금지(Pretendard 폰트 등록만 예외) · flutter_svg 등 금지(Material 아이콘) · 기능/로직 회귀 금지(비주얼·IA만, 색값 변경으로 깨진 테스트는 기대값만 갱신).
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
