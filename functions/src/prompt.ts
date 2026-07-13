import { SeedQuestion } from "./seed";
import { GenRequest } from "./schema";

/// 시드 few-shot + 규칙으로 system/user 프롬프트를 조립한다.
/// 핵심 안전장치: 예시는 스타일·난이도 기준일 뿐 "복제 금지, 변형 창작"을 강제(ADR-0002).
export function buildPrompt(args: {
  input: GenRequest;
  fewShot: SeedQuestion[];
}): { system: string; user: string } {
  const { input, fewShot } = args;
  const typeLabel =
    input.type === "mcq"
      ? "4지선다 객관식"
      : input.type === "ox"
        ? "O/X"
        : "객관식과 O/X 혼합";

  const system = [
    "당신은 대한민국 소방공무원 공채 '소방관계법규' 심화 문제 출제자다.",
    "규칙:",
    "1. 법령·수치·요건은 반드시 정확해야 한다. 확신이 없으면 그 소재를 피하라(틀린 법령 노출은 치명적).",
    "2. 예시 문제는 스타일·난이도 기준일 뿐이다. 문장·보기·숫자를 그대로 복제하지 말고, 새로운 사례·조합·수치로 변형해 창작하라.",
    "3. 심화 축을 적극 활용하라: 교차법령(여러 법률 결합)·개수형(옳은 개수)·조건부 계산·예외조항.",
    "4. mcq는 보기 4개·정답 1개. ox는 보기 ['O','X'] 형식(answerIndex: O=0, X=1).",
    "5. 개수형 문항이면 breakdown에 보기별 label(ㄱ·ㄴ…)·correct·거짓 교정(note)을 채워라. 개수형이 아니면 breakdown은 빈 배열([]).",
    "6. explanation은 정답 근거를 법령 기준으로 간결히 서술하라.",
  ].join("\n");

  const examples = fewShot
    .map(
      (q, i) =>
        `예시 ${i + 1} [${q.type}] ${q.stem}\n보기: ${JSON.stringify(
          q.choices,
        )}\n정답index: ${q.answerIndex}\n해설: ${q.explanation}`,
    )
    .join("\n\n");

  const user = [
    `아래 예시(참고용 · 복제 금지)를 참고해 새 ${typeLabel} 문제 ${input.count}개를 생성하라.`,
    "",
    "=== 참고 예시 ===",
    examples,
    "=== 예시 끝 ===",
    "",
    `요구: 유형=${
      input.type === "mixed" ? "mcq/ox 혼합" : input.type
    }, 개수=${input.count}. 각 문제는 위 규칙을 모두 지킬 것.`,
  ].join("\n");

  return { system, user };
}
