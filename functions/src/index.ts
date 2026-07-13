import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import { initializeApp } from "firebase-admin/app";

import { RequestSchema, validateQuestions } from "./schema";
import { loadSeed, filterByYear, sampleFewShot } from "./seed";
import { buildPrompt } from "./prompt";
import { callAnthropic } from "./claude";
import { checkAndIncrement } from "./ratelimit";

initializeApp();

const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");
const DAILY_LIMIT = 3;
const FEW_SHOT_N = 6;

/// AI 실시간 문제 생성 (앱 → callable). 앱에는 API 키가 없고 이 프록시만 호출한다.
export const generateQuestions = onCall(
  {
    region: "asia-northeast3", // Seoul
    secrets: [ANTHROPIC_API_KEY],
    enforceAppCheck: false, // TODO: 앱에 App Check 연동 후 true (URL 유출 시 남용 방어)
    timeoutSeconds: 300,
    memory: "512MiB",
  },
  async (req) => {
    // 1) 요청 검증
    const parsed = RequestSchema.safeParse(req.data);
    if (!parsed.success) {
      throw new HttpsError(
        "invalid-argument",
        `요청 형식 오류: ${parsed.error.message}`,
      );
    }
    const input = parsed.data;

    // 2) 레이트리밋(일 DAILY_LIMIT회)
    const remaining = await checkAndIncrement(input.installId, DAILY_LIMIT);
    if (remaining < 0) {
      throw new HttpsError(
        "resource-exhausted",
        `일일 생성 한도(${DAILY_LIMIT}회)를 초과했습니다.`,
      );
    }

    // 3) 시드 선택 + 프롬프트 조립
    const pool = filterByYear(loadSeed(), input.yearScope);
    if (pool.length === 0) {
      throw new HttpsError("failed-precondition", "해당 년도 시드가 없습니다.");
    }
    const prompt = buildPrompt({
      input,
      fewShot: sampleFewShot(pool, FEW_SHOT_N),
    });

    // 4) 생성 호출
    let raw;
    try {
      raw = await callAnthropic(ANTHROPIC_API_KEY.value(), prompt);
    } catch (e) {
      throw new HttpsError("internal", `생성 실패: ${(e as Error).message}`);
    }

    // 5) 응답 검증
    const questions = validateQuestions(raw);
    if (questions.length === 0) {
      throw new HttpsError("internal", "유효한 문제를 생성하지 못했습니다.");
    }

    return {
      questions,
      meta: {
        model: "claude-opus-4-8",
        yearScope: input.yearScope,
        requested: input.count,
        produced: questions.length,
        remainingToday: remaining,
      },
    };
  },
);
