import Anthropic from "@anthropic-ai/sdk";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";
import { GenResultSchema, GenQuestion } from "./schema";

/// 생성 provider(현재 Anthropic Claude). bake-off 대안(예: 다른 provider)은
/// 같은 시그니처의 형제 모듈로 추가하고 index에서 스위칭한다(ADR-0002 provider 추상화).
export async function callAnthropic(
  apiKey: string,
  prompt: { system: string; user: string },
): Promise<GenQuestion[]> {
  const client = new Anthropic({ apiKey });

  // structured output: zod 스키마로 형식을 강제하고 자동 검증(parsed_output).
  const response = await client.messages.parse({
    model: "claude-opus-4-8",
    max_tokens: 16000,
    thinking: { type: "adaptive" }, // 법령 정확성 위해 사고 활성
    output_config: {
      effort: "high",
      format: zodOutputFormat(GenResultSchema),
    },
    system: prompt.system,
    messages: [{ role: "user", content: prompt.user }],
  });

  if (!response.parsed_output) {
    throw new Error("structured output 파싱 실패(parsed_output=null)");
  }
  return response.parsed_output.questions;
}
