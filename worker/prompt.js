'use strict';
const fs = require('fs');
const path = require('path');

// 그라운딩 시드 = 앱 번들 뱅크(같은 repo). 백엔드 비공개 원칙상 원문은 노출 안 하고
// 스타일·난이도 기준(few-shot)으로만 쓴다(ADR-0002).
const BANK_PATH = path.join(__dirname, '..', 'assets', 'content', 'fire-law.json');
// 실제 2026 기출 참고 세트도 시드에 합친다(진짜 기출 문장·난이도 그라운딩).
const AI_REF_PATH = path.join(__dirname, '..', 'assets', 'content', 'fire-law-2026-ai.json');

function loadBank() {
  const bank = JSON.parse(fs.readFileSync(BANK_PATH, 'utf-8')).questions;
  const aiRef = JSON.parse(fs.readFileSync(AI_REF_PATH, 'utf-8')).questions
      // 그림형(선택지 이미지)은 텍스트 few-shot로 부적합 → 제외.
      .filter((q) => !(q.choiceImages && q.choiceImages.length))
      // 해설의 '(ai 생성)' 접두는 시드로 새어들지 않게 제거.
      .map((q) => ({ ...q, explanation: q.explanation.replace(/^\(ai 생성\)\s*/, '') }));
  return [...bank, ...aiRef];
}

function filterByYear(all, scope) {
  if (scope === 'all') return all;
  // 2026 소방공채 기출문제 = 실제 기출 참고 세트(source='ai')만 시드로.
  if (scope === 'gichul-2026') return all.filter((q) => q.source === 'ai');
  const y = scope === '2025' ? 2025 : 2026;
  return all.filter((q) => q.year === y);
}

function sampleFewShot(pool, n) {
  const arr = [...pool];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr.slice(0, Math.min(n, arr.length));
}

function buildPrompt({ input, fewShot }) {
  const typeLabel =
    input.type === 'mcq' ? '4지선다 객관식'
    : input.type === 'ox' ? 'O/X'
    : '객관식과 O/X 혼합';

  const system = [
    "당신은 대한민국 소방공무원 공채 '소방관계법규' 심화 문제 출제자다.",
    '규칙:',
    '1. 법령·수치·요건은 반드시 정확해야 한다. 확신이 없으면 그 소재를 피하라(틀린 법령 노출은 치명적).',
    '2. 예시 문제는 스타일·난이도 기준일 뿐이다. 문장·보기·숫자를 그대로 복제하지 말고, 새로운 사례·조합·수치로 변형해 창작하라.',
    '3. 심화 축을 적극 활용하라: 교차법령(여러 법률 결합)·개수형(옳은 개수)·조건부 계산·예외조항.',
    "4. mcq는 보기 4개·정답 1개. ox는 보기 ['O','X'] 형식(answerIndex: O=0, X=1).",
    '5. 개수형 문항이면 breakdown에 보기별 label(ㄱ·ㄴ…)·correct·거짓 교정(note)을 채워라. 개수형이 아니면 breakdown은 빈 배열([]).',
    '6. explanation은 정답 근거를 법령 기준으로 간결히 서술하라.',
  ].join('\n');

  const examples = fewShot
    .map((q, i) =>
      `예시 ${i + 1} [${q.type}] ${q.stem}\n보기: ${JSON.stringify(q.choices)}\n정답index: ${q.answerIndex}\n해설: ${q.explanation}`)
    .join('\n\n');

  const user = [
    `아래 예시(참고용 · 복제 금지)를 참고해 새 ${typeLabel} 문제 ${input.count}개를 생성하라.`,
    '',
    '=== 참고 예시 ===',
    examples,
    '=== 예시 끝 ===',
    '',
    `요구: 유형=${input.type === 'mixed' ? 'mcq/ox 혼합' : input.type}, 개수=${input.count}. 각 문제는 위 규칙을 모두 지킬 것.`,
    '',
    '출력은 반드시 JSON만. 형식: {"questions":[{"type","stem","choices":[],"answerIndex","explanation","tags":[],"breakdown":[]}]}',
  ].join('\n');

  return { system, user };
}

module.exports = { loadBank, filterByYear, sampleFewShot, buildPrompt };
