# deck119-functions — AI 실시간 문제 생성 백엔드

앱에는 Claude API 키가 없다. 앱은 이 Firebase Callable Function(`generateQuestions`)만 호출하고,
키·시드·레이트리밋은 전부 서버에 있다. (결정: [ADR-0002])

## 함수가 하는 일 (5)

1. **요청 검증** — `{subjectId, yearScope, count, type, installId}` (zod)
2. **레이트리밋** — installId 기준 일 3회 (Firestore `gen_rate_limits`)
3. **시드 선택 + 프롬프트 조립** — `seed/fire-law.json`을 yearScope로 필터(2025→58 / 2026→275 / all→333) → few-shot 6개 → "복제 금지·변형 창작" 규칙
4. **생성 호출** — `claude-opus-4-8`, structured output(zod)
5. **응답 검증** — 형식 깨진 문항 폐기 후 반환

## 로컬 설정

```bash
cd functions
npm install
npm run build          # tsc → lib/
```

## 시크릿(API 키) 등록

앱·코드에 키를 넣지 않는다. Firebase Secret Manager에만 둔다.

```bash
firebase functions:secrets:set ANTHROPIC_API_KEY
# 프롬프트에 키 붙여넣기
```

## 배포

```bash
firebase deploy --only functions
```

## 시드 동기화 ⚠️

`seed/fire-law.json`은 앱 번들 `assets/content/fire-law.json`의 복사본이다(마스터 = vault `Output/content/fire-law.bank.json`).
뱅크가 바뀌면 수동 미러:

```bash
cp ../assets/content/fire-law.json seed/fire-law.json
```

## 남은 TODO

- **App Check**: 앱 연동 후 `enforceAppCheck: true` (URL 유출 시 남용 방어)
- **자가검증 2차 패스**: 생성물 법령 정확성 재검(품질 향상용, ADR-0002)
- **provider bake-off**: `claude.ts` 시그니처를 따르는 대안 provider 모듈

[ADR-0002]: ../../../obsidian_workspace/personal_dev_wiki/wiki/projects/소방-기출앱/adr/ADR-0002-AI-실시간-생성-백엔드.md
