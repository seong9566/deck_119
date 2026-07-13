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
- 죽어도 살아나게 하려면 `pm2 start index.js --name deck119-worker` 또는 launchd 등록.

## 동작 확인

워커 실행 후 앱에서 "AI 문제 생성" → 콘솔에 `[claim] … [done] …N문항` 로그가 뜨면 정상.

## 참고

- 시드 = 앱 번들 `../assets/content/fire-law.json`(별도 사본 없음).
- CLI 출력 JSON 파싱은 API 구조화출력보다 덜 안정적 → 실패 시 doc `status=error`로 기록, 앱은 에러 표시.
- 파킹된 대안 경로: `../functions/`(Firebase Functions + 유료 API). 현재 미사용.
