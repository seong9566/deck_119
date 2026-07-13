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
const { loadBank, filterByYear, sampleFewShot, buildPrompt } = require('./prompt');

const execFileP = promisify(execFile);

// ── 설정 ────────────────────────────────────────────────
// 서비스 계정 키: 콘솔에서 다운로드 → GOOGLE_APPLICATION_CREDENTIALS 또는 ./service-account.json
const KEY_PATH =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  path.join(__dirname, 'service-account.json');

// 로컬 CLI. 기본 Claude Code(`claude`). 다른 CLI면 GEN_CLI로 교체하고 buildArgs 수정.
const CLI = process.env.GEN_CLI || 'claude';
const buildArgs = (prompt) => ['-p', prompt, '--output-format', 'json'];

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
    const questions = validate(await generate(prompt));
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

// CLI 호출 → 모델 출력에서 questions[] 파싱.
async function generate(prompt) {
  const full = `${prompt.system}\n\n${prompt.user}`;
  // 중립 임시 폴더에서 실행 → 프로젝트 CLAUDE.md 등 컨텍스트 주입 방지(노이즈·지연·비용↓).
  const { stdout } = await execFileP(CLI, buildArgs(full), {
    cwd: os.tmpdir(),
    maxBuffer: 10 * 1024 * 1024,
  });
  // `claude -p --output-format json`은 봉투 JSON({type,result,...}). result에 모델 텍스트.
  let text = stdout;
  try {
    const env = JSON.parse(stdout);
    text = env.result ?? env.content ?? stdout;
  } catch (_) {
    /* 봉투가 아니면 원문 그대로 파싱 */
  }
  return parseQuestions(text);
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

console.log(`worker up (CLI=${CLI}). watching ${COLLECTION}(status=pending)…`);
