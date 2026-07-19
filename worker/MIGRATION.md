# 워커 이전 가이드 — 다른 맥으로 옮기기 (예: 맥 스튜디오)

AI 문제 생성 워커(`worker/`)를 다른 맥으로 옮길 때의 절차. Firestore는 클라우드라
**데이터 이전은 없다**(두 맥이 같은 DB를 본다). 워커 코드는 대부분 git에 있어 clone하면 되고,
**비밀키 복사 · claude 로그인 · plist 경로 수정** 세 가지만 수동으로 챙기면 된다.

## 이전 대상 요약

| 항목 | 방법 | 이유 |
|---|---|---|
| 워커 코드 (`worker/`) | git clone | 커밋돼 있음 |
| `worker/service-account.json` | **수동 복사 (비밀키)** | git 제외 — 없으면 Firestore 접속 불가 |
| `.env` | 선택 (Discord 웹훅뿐) | 없어도 워커 동작함 |
| `claude` CLI | 새 맥에 설치 + **로그인** | 인증은 키체인에 있어 복사 안 됨 |
| launchd plist | **경로/사용자명 수정 후 설치** | 이 맥 기준 하드코딩 |

---

## 1. 사전 준비 (새 맥)

```bash
# node 설치 (Homebrew)
brew install node

# claude 설치 + 로그인 (반드시 로그인까지!)
claude                                    # 로그인 진행
claude -p "안녕" --output-format json      # 동작 확인
```

## 2. 레포 clone + 워커 의존성

```bash
git clone <레포URL> ~/원하는/경로/deck_119
cd ~/원하는/경로/deck_119/worker
npm install
```

## 3. 비밀키 복사 (기존 맥 → 새 맥)

AirDrop / scp 등으로 아래 파일 **하나**를 복사한다. git엔 절대 올라가지 않는다.

```
worker/service-account.json
```

## 4. 수동 실행으로 먼저 검증 (launchd 걸기 전)

```bash
cd worker && npm run start
# → "worker up ... watching gen_requests(status=pending)…" 뜨면 OK
# 앱에서 AI 문제 생성 → [claim] … [done] …N문항 로그 확인
```

## 5. 상시구동 (launchd) — plist 경로 수정이 핵심

### 5-1. 새 맥에서 정확한 값 먼저 확인

```bash
whoami                              # → 새 사용자명
command -v node                     # → node 절대경로
readlink -f "$(command -v claude)"  # → claude 실제 바이너리 절대경로 (alias 아님!)
pwd                                 # worker 폴더에서 → WorkingDirectory 경로
```

### 5-2. plist 치환 위치 (6군데)

`launchd/com.seong.deck119.worker.plist`를 복사해 편집한다.
사실상 **`ihyeonseong` → `<새사용자명>` 전체 치환** + node/claude 경로 2개만 개별 확인.

| 위치 | 이 맥 값 | 새 맥으로 |
|---|---|---|
| `ProgramArguments` node | `/opt/homebrew/bin/node` | `command -v node` 결과 |
| `WorkingDirectory` | `/Users/ihyeonseong/Desktop/workspace/side_project/deck_119/worker` | 새 맥의 worker 절대경로 |
| `GEN_CLI` | `/Users/ihyeonseong/.local/bin/claude` | `readlink -f $(command -v claude)` 결과 |
| `HOME` | `/Users/ihyeonseong` | `/Users/<새사용자명>` |
| `USER` | `ihyeonseong` | `<새사용자명>` |
| `LOGNAME` | `ihyeonseong` | `<새사용자명>` |
| `StandardOutPath` / `StandardErrorPath` | `/Users/ihyeonseong/Library/Logs/deck119-worker.log` | `/Users/<새사용자명>/Library/Logs/deck119-worker.log` |

### 5-3. 설치

```bash
cp worker/launchd/com.seong.deck119.worker.plist ~/Library/LaunchAgents/
plutil -lint ~/Library/LaunchAgents/com.seong.deck119.worker.plist   # 문법 검증
launchctl load -w ~/Library/LaunchAgents/com.seong.deck119.worker.plist
launchctl list | grep deck119                                        # 등록 확인
tail -f ~/Library/Logs/deck119-worker.log                            # "worker up … watching" 확인
```

## 6. 기존 맥 워커 중지

두 대가 같이 caffeinate로 안 자고 돌지 않도록 기존 맥은 꺼준다.

```bash
launchctl unload ~/Library/LaunchAgents/com.seong.deck119.worker.plist
```

> 중복 처리 자체는 안전하다(`pending → processing` 트랜잭션 선점으로 한 요청은 한 번만 처리).
> 하지만 "옮기는" 것이므로 기존 워커는 꺼주는 게 맞다.

---

## ⚠️ 가장 흔한 실패 3가지

1. **`HOME`/`USER`/`LOGNAME` 중 하나라도 틀림** → keychain을 못 열어 `"Not logged in"`으로 문제 생성 실패.
2. **`GEN_CLI`를 alias나 심볼릭 경로로 지정** → launchd의 `execFile`은 alias/PATH를 타지 않는다. 반드시 `readlink -f`로 확인한 **실제 바이너리 절대경로**.
3. **`service-account.json` 복사 누락** → Firestore 접속 자체가 안 됨.
