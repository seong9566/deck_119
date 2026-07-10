# 119덱 (deck_119) — Claude Code 운영 지침

소방공채 심화·OX 문제 앱. **MVVM + 클린 아키텍처 · Flutter · Android/iOS**.

## 시작 전 필독

- **`docs/BUILD_PLAN.md`** = MVP 빌드의 단일 진실원. 확정 결정·영속화 스펙·화면 정의서·태스크(DoD)·검증 런북·가드레일이 전부 있다. 작업 전 반드시 읽고 그 순서대로 진행한다.
- 상위 맥락(왜)이 필요하면 vault: `~/Desktop/obsidian_workspace/personal_dev_wiki/wiki/projects/소방-기출앱/` (PRD·ADR-0001·architecture).

## 핵심 규칙

- 언어: 한국어.
- **의존성**: `docs/BUILD_PLAN.md` §0 허용목록 내에서만 추가. 그 외는 추가하지 말고 대안 구현 또는 스킵 후 `docs/BUILD_LOG.md`에 기록.
- **콘텐츠 불변**: `assets/content/*.json`의 지문·정답·해설은 검수 완료값 — 수정 금지.
- **레이어**: `lib/domain`은 Flutter·Isar import 0. `presentation`은 UseCase만 호출. 저장소 교체는 `data/**/impl`에서만.
- **범위**: MVP Must만(PRD Won't = 검색·북마크·통계 대시보드·클라우드 동기화 — 만들지 말 것).
- **검증 루프**: 각 태스크 = 구현 → `flutter analyze`(이슈 0) → 관련 테스트 작성·통과. Isar 스키마 변경 시 `dart run build_runner build --delete-conflicting-outputs`.
- **정직 보고**: 못 한 것·추측·스킵은 `docs/BUILD_LOG.md`에 그대로. 오버클레임 금지.
- **커밋**(git 있을 때만): 태스크 단위, 한국어 메시지, 끝에 `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.

## 구조

```
lib/domain/{entities,repositories,usecases}   # 순수 Dart
lib/data/{datasources,models,repositories}     # 콘텐츠(JSON)·저장(Isar)
lib/presentation/{home,quiz,settings,shared}   # MVVM(View↔ViewModel)
assets/content/fire-law.json                   # 25문항 시드
```

## 태스크 라이프사이클 (PM↔코드) — toss와 동일 워크플로우

소스 오브 트루스 = **PM vault**의 `wiki/projects/소방-기출앱/tasks/<ID>.md` 프론트매터. 프로토콜 원문: vault `wiki/harness/task-lifecycle-pm-code.md`.

- 태스크는 `T1`~`T8` (= `docs/BUILD_PLAN.md` §4). 시작 시 **브랜치명에 ID**: `git checkout -b feat/T1-isar-bootstrap`.
- 완료 커밋/PR엔 trailer **`Closes: T1`** (없으면 진행중 유지).
- 상태는 훅이 자동 전환:
  - 세션 종료 시 `.claude/settings.json`의 **Stop 훅** → 브랜치 ID를 `wip`.
  - 커밋 시 **`.githooks/post-commit`** → `Closes: Tx`를 `done`.
- 수동 전환:
  ```bash
  VAULT=/Users/ihyeonseong/Desktop/obsidian_workspace/personal_dev_wiki
  bash "$VAULT/.claude/scripts/task.sh" wip  T1 --section code
  bash "$VAULT/.claude/scripts/task.sh" done T1
  bash "$VAULT/.claude/scripts/task.sh" ls   --project 소방-기출앱
  ```
- **최초 1회 설치**(git init 후): `git config core.hooksPath .githooks` — post-commit 훅 활성화.
- Discord 작업보고(선택): `.env`에 `DISCORD_WEBHOOK_URL=...` 넣으면 상태 전환 시 자동 알림(task.sh 내장, fail-soft).
