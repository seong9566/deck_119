import * as fs from "fs";
import * as path from "path";

/// 그라운딩 시드(년도별 기출/동형 파생 코퍼스). 백엔드 비공개 — 원문은 앱·응답에 노출하지 않고
/// 스타일·난이도 기준(few-shot)으로만 쓴다(ADR-0002 안전장치).
export interface SeedQuestion {
  id: string;
  type: string;
  year: number | null;
  stem: string;
  choices: string[];
  answerIndex: number;
  explanation: string;
  tags: string[];
  breakdown?: { label: string; correct: boolean; note?: string }[];
}

let cache: SeedQuestion[] | null = null;

export function loadSeed(): SeedQuestion[] {
  if (cache) return cache;
  // 컴파일 산출물은 lib/ 에 있으므로 ../seed 로 올라간다.
  const p = path.join(__dirname, "..", "seed", "fire-law.json");
  const json = JSON.parse(fs.readFileSync(p, "utf-8"));
  cache = json.questions as SeedQuestion[];
  return cache;
}

export function filterByYear(
  all: SeedQuestion[],
  scope: "2025" | "2026" | "all",
): SeedQuestion[] {
  if (scope === "all") return all;
  const y = scope === "2025" ? 2025 : 2026;
  return all.filter((q) => q.year === y);
}

/// few-shot 예시를 무작위 샘플링(호출마다 다른 예시로 다양성 확보).
export function sampleFewShot(pool: SeedQuestion[], n: number): SeedQuestion[] {
  const arr = [...pool];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr.slice(0, Math.min(n, arr.length));
}
