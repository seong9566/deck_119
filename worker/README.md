# deck119-worker — AI 문제 생성 워커 (맥북 상시 구동)

앱이 Firestore `gen_requests`에 요청을 쓰면, 이 워커가 감지해 **로컬 CLI**로 문제를 생성하고
결과를 같은 doc에 기록한다. 앱은 그 doc을 구독하다 결과를 받는다. (Firebase Functions 불필요 → Blaze 불필요)

```
앱 → Firestore(gen_requests, pending) → [이 워커] 감지 → CLI 생성 → doc(done, questions) → 앱
```

## 1. 서비스 계정 키

Firebase 콘솔 → ⚙️ 프로젝트 설정 → **서비스 계정** → "새 비공개 키 생성" → JSON 다운로드
→ 이 파일을 `worker/service-account.json`으로 저장. (git 무시됨 · 절대 커밋 금지)

## 2. Firestore 활성화

콘솔 → **Firestore Database** → 데이터베이스 만들기(Native 모드). 무료 Spark로 충분.
규칙 배포(리포 루트에서):

```bash
firebase deploy --only firestore:rules
```

## 3. 로컬 CLI

기본값은 Claude Code(`claude`). 설치·로그인돼 있어야 한다:

```bash
claude -p "안녕" --output-format json    # 동작 확인
```

다른 CLI를 쓰려면 `GEN_CLI` 환경변수 + `index.js`의 `buildArgs` 수정.

⚠️ **약관**: 구독/CLI 인증을 앱 백엔드로 자동 처리하는 것은 개인·대화형 용도를 벗어나 정책 위반 소지가 있음(감수 여부는 운영자 판단).

## 4. 실행

```bash
cd worker
npm install
npm run start          # 일반 실행
npm run start:awake    # caffeinate로 시스템 잠자기 방지(권장)
```

- **노트북을 덮으면 잠들어 멈춤** → 클램셸/전원설정 주의.

### 상시 구동 (launchd — 로그인 자동 시작 + 자동 재시작, 권장)

`launchd/com.seong.deck119.worker.plist`를 설치하면 로그인 시 자동 시작·죽으면 재시작·caffeinate 슬립 방지가 모두 걸린다.

```bash
cp worker/launchd/com.seong.deck119.worker.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/com.seong.deck119.worker.plist
```

- ⚠️ **claude 인증은 키체인에 저장**된다. plist `EnvironmentVariables`에 `HOME`·`USER`·`LOGNAME`이 **반드시** 있어야 keychain을 열어 인증한다(없으면 `"Not logged in"`으로 생성 실패). `GEN_CLI`는 claude **실제 바이너리 절대경로**(zsh alias가 아님 — `command -v claude`로 확인).
- 경로·사용자명은 이 맥(`ihyeonseong`) 기준 하드코딩 — 다른 환경이면 plist를 수정.
- 로그: `~/Library/Logs/deck119-worker.log` (`tail -f`로 관찰). 상태: `launchctl list | grep deck119`.
- 중지/해제: `launchctl unload ~/Library/LaunchAgents/com.seong.deck119.worker.plist`.

## 동작 확인

워커 실행 후 앱에서 "AI 문제 생성" → 콘솔에 `[claim] … [done] …N문항` 로그가 뜨면 정상.

## 참고

- 시드 = 앱 번들 `../assets/content/fire-law.json` + 실제 2026 기출 참고 세트 `../assets/content/fire-law-2026-ai.json`(그림형 제외). 별도 사본 없음.
- CLI 출력 JSON 파싱은 API 구조화출력보다 덜 안정적 → 실패 시 doc `status=error`로 기록, 앱은 에러 표시.
- 파킹된 대안 경로: `../functions/`(Firebase Functions + 유료 API). 현재 미사용.
