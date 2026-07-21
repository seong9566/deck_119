'use strict';
// launchd 등 파일 리다이렉트에서 stdout이 블록버퍼링되면 로그가 안 보인다 → 즉시 flush.
try {
  process.stdout._handle?.setBlocking?.(true);
  process.stderr._handle?.setBlocking?.(true);
} catch (_) {
  /* 환경에 따라 _handle이 없을 수 있음(무시) */
}
const admin = require('firebase-admin');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { execFile } = require('child_process');
const { promisify } = require('util');
const path = require('path');
const os = require('os');
const fs = require('fs');
const { loadBank, filterByYear, sampleFewShot, buildPrompt } = require('./prompt');

const execFileP = promisify(execFile);

// ── 설정 ────────────────────────────────────────────────
// 서비스 계정 키: 콘솔에서 다운로드 → GOOGLE_APPLICATION_CREDENTIALS 또는 ./service-account.json
const KEY_PATH =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  path.join(__dirname, 'service-account.json');

// 생성 CLI 2종. 기본 Claude(-p json 봉투), 실패 시 폴백 Codex(exec -o 파일).
// CLAUDE_CLI는 레거시 GEN_CLI도 인정(기존 launchd plist가 GEN_CLI로 claude 절대경로 주입 중).
const CLAUDE_CLI = process.env.CLAUDE_CLI || process.env.GEN_CLI || 'claude';
const CODEX_CLI = process.env.CODEX_CLI || 'codex';
// codex 기본 reasoning effort=high는 문제 창작에 수 분 걸림 → per-invocation으로 낮춘다
// (전역 ~/.codex/config.toml은 안 건드림). 배포 때 CODEX_EFFORT로 조정. 실측: medium≈87s·low≈61s.
const CODEX_EFFORT = process.env.CODEX_EFFORT || 'medium';
const claudeArgs = (prompt) => ['-p', prompt, '--output-format', 'json'];
// 프롬프트는 stdin으로(끝 인자 `-`). tmpdir는 git repo가 아니라 --skip-git-repo-check 필요.
// read-only = 텍스트 생성만(쉘 명령·쓰기 없음, 승인 프롬프트도 안 뜸).
const codexArgs = (outFile) => [
  'exec', '--skip-git-repo-check', '--sandbox', 'read-only',
  '-c', `model_reasoning_effort="${CODEX_EFFORT}"`,
  '-o', outFile, '-',
];

const FEW_SHOT_N = 6;
const COLLECTION = 'gen_requests';
// Firestore 데이터베이스 id. 기본 `(default)`가 아니라 명명된 DB를 씀.
const DATABASE_ID = process.env.FIRESTORE_DB || 'deck-119-db';
// ────────────────────────────────────────────────────────

admin.initializeApp({ credential: admin.credential.cert(require(KEY_PATH)) });
const db = getFirestore(DATABASE_ID);
const bank = loadBank();

async function handle(doc) {
  const ref = doc.ref;
  // pending → processing 선점(트랜잭션, 중복 처리 방지).
  const claimed = await db.runTransaction(async (tx) => {
    const s = await tx.get(ref);
    if (s.get('status') !== 'pending') return false;
    tx.update(ref, { status: 'processing', updatedAt: FieldValue.serverTimestamp() });
    return true;
  });
  if (!claimed) return;

  const data = doc.data();
  console.log(`[claim] ${ref.id} year=${data.yearScope} type=${data.type} n=${data.count}`);
  try {
    const pool = filterByYear(bank, data.yearScope);
    if (!pool.length) throw new Error('해당 년도 시드가 없습니다.');
    const prompt = buildPrompt({ input: data, fewShot: sampleFewShot(pool, FEW_SHOT_N) });
    const questions = await generate(prompt);
    if (!questions.length) throw new Error('유효한 문제를 생성하지 못했습니다.');
    await ref.update({
      status: 'done',
      questions,
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.log(`[done]  ${ref.id} → ${questions.length}문항`);
  } catch (e) {
    await ref.update({
      status: 'error',
      error: String(e.message || e).slice(0, 300),
      updatedAt: FieldValue.serverTimestamp(),
    });
    console.error(`[error] ${ref.id}: ${e.message}`);
  }
}

// Claude 호출 → 봉투 검사 → questions[] 파싱. 실패 신호면 throw(폴백 유도).
async function runClaude(full) {
  const { stdout } = await execFileP(CLAUDE_CLI, claudeArgs(full), {
    cwd: os.tmpdir(),
    maxBuffer: 10 * 1024 * 1024,
  });
  // claude -p --output-format json 은 봉투 JSON({type,result,is_error,...}).
  const env = JSON.parse(stdout);
  if (env.is_error || env.api_error_status || String(env.subtype ?? '').startsWith('error')) {
    throw new Error(`claude 실패: subtype=${env.subtype} api=${env.api_error_status}`);
  }
  return parseQuestions(env.result ?? env.content ?? stdout);
}

// Codex 호출 → 최종 메시지 파일(-o) 읽기 → questions[] 파싱. 실패면 throw.
async function runCodex(full) {
  const outFile = path.join(os.tmpdir(), `codex-out-${process.pid}-${Date.now()}.txt`);
  try {
    // 프롬프트는 stdin으로 넘기고 즉시 EOF. codex는 파이프된 stdin의 EOF를 기다리므로,
    // positional로 주면 execFile이 stdin을 안 닫아 무한 대기한다(실측). 최종 메시지는 -o 파일에서 읽는다.
    const proc = execFileP(CODEX_CLI, codexArgs(outFile), {
      cwd: os.tmpdir(),
      maxBuffer: 10 * 1024 * 1024,
    });
    proc.child.stdin.end(full);
    await proc;
    return parseQuestions(fs.readFileSync(outFile, 'utf-8'));
  } finally {
    fs.rmSync(outFile, { force: true });
  }
}

// Claude 우선. 하드 실패(프로세스·API·limit)든 콘텐츠 실패(파싱·유효문항 0)든
// 실패하면 codex로 1회 폴백. validate까지 통과한 문항 배열을 반환.
async function generate(prompt) {
  const full = `${prompt.system}\n\n${prompt.user}`;
  try {
    const questions = validate(await runClaude(full));
    if (!questions.length) throw new Error('claude: 유효 문항 0개');
    return questions;
  } catch (e) {
    console.warn(`[fallback] claude 실패 → codex 재시도: ${e.message}`);
    const questions = validate(await runCodex(full));
    if (!questions.length) throw new Error('codex 폴백도 유효 문항 0개');
    return questions;
  }
}

function parseQuestions(text) {
  const cleaned = String(text).replace(/```json/gi, '').replace(/```/g, '');
  const start = cleaned.indexOf('{');
  const end = cleaned.lastIndexOf('}');
  if (start < 0 || end < 0) throw new Error('JSON 파싱 실패(모델 출력에 JSON 없음)');
  const obj = JSON.parse(cleaned.slice(start, end + 1));
  return Array.isArray(obj.questions) ? obj.questions : [];
}

// 형식 검증 + 정규화(앱 스키마에 맞춤). 깨진 문항 폐기.
function validate(items) {
  return items
    .filter((q) => {
      if (q.type === 'ox') return q.answerIndex === 0 || q.answerIndex === 1;
      return (
        Array.isArray(q.choices) &&
        q.choices.length >= 2 &&
        q.choices.length <= 5 &&
        q.answerIndex >= 0 &&
        q.answerIndex < q.choices.length
      );
    })
    .map((q) => ({
      type: q.type === 'ox' ? 'ox' : 'mcq',
      stem: String(q.stem ?? ''),
      choices: q.type === 'ox' ? ['O', 'X'] : (q.choices ?? []).map(String),
      answerIndex: Number(q.answerIndex ?? 0),
      explanation: String(q.explanation ?? ''),
      tags: Array.isArray(q.tags) ? q.tags.map(String) : [],
      breakdown: Array.isArray(q.breakdown)
        ? q.breakdown.map((b) => ({
            label: String(b.label ?? ''),
            correct: !!b.correct,
            note: String(b.note ?? ''),
          }))
        : [],
    }));
}

// 처리 중 예외가 프로세스를 죽이지 않게 최종 방어(claim 트랜잭션 실패 등).
process.on('unhandledRejection', (e) =>
  console.error('[unhandledRejection]', e && e.message ? e.message : e));

// pending 요청 감시(추가되는 즉시 처리).
db.collection(COLLECTION)
  .where('status', '==', 'pending')
  .onSnapshot(
    (snap) => {
      snap.docChanges().forEach((ch) => {
        // handle은 fire-and-forget이라 rejection을 반드시 여기서 삼킨다(크래시 방지).
        if (ch.type === 'added') {
          handle(ch.doc).catch((e) =>
            console.error(`[handle] ${ch.doc.id} 실패:`, e && e.message ? e.message : e));
        }
      });
    },
    (err) => console.error('watch error:', err),
  );

console.log(`worker up (claude→codex 폴백). watching ${COLLECTION}(status=pending)…`);

// 테스트/재사용을 위한 export(워커 실행 시엔 무영향).
module.exports = { generate, runClaude, runCodex, parseQuestions, validate };
