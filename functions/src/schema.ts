// zodOutputFormat 헬퍼가 zod/v4 스키마를 요구하므로 v4 서브패스에서 import.
import * as z from "zod/v4";

/// 앱 → 함수 요청 계약. 앱은 이 4가지 + 기기 식별자만 보낸다.
export const RequestSchema = z.object({
  subjectId: z.literal("fire-law"), // 현재 과목은 소방관계법규 하나
  yearScope: z.enum(["2025", "2026", "all"]),
  count: z.number().int().min(1).max(5), // 회당 최대 5문항(일 3회 한도와 별개)
  type: z.enum(["mcq", "ox", "mixed"]),
  installId: z.string().min(4), // 레이트리밋 키(기기 설치 id, 방어적 상한용)
});
export type GenRequest = z.infer<typeof RequestSchema>;

/// 모델이 생성할 문제 스키마. 앱 Question 중 창작 대상 필드만.
/// (id·subjectId·year·difficulty·source 는 앱이 부여)
export const GenQuestionSchema = z.object({
  type: z.enum(["mcq", "ox"]),
  stem: z.string(),
  choices: z.array(z.string()), // mcq: 4개 / ox: ["O","X"]
  answerIndex: z.number().int(), // 0-based (ox: O=0, X=1)
  explanation: z.string(),
  tags: z.array(z.string()),
  // 개수형(<보기> 중 옳은 개수) 문항의 보기별 판정. 개수형이 아니면 빈 배열.
  breakdown: z.array(
    z.object({
      label: z.string(), // ㄱ·ㄴ…
      correct: z.boolean(),
      note: z.string(), // 거짓일 때 교정, 옳으면 ""
    }),
  ),
});
export type GenQuestion = z.infer<typeof GenQuestionSchema>;

export const GenResultSchema = z.object({
  questions: z.array(GenQuestionSchema),
});

/// 스키마 통과 후의 논리 검증. 형식이 깨진 문항은 버린다.
export function validateQuestions(items: GenQuestion[]): GenQuestion[] {
  return items
    .filter((q) => {
      if (q.type === "ox") {
        return q.answerIndex === 0 || q.answerIndex === 1;
      }
      // mcq
      if (q.choices.length < 2 || q.choices.length > 5) return false;
      if (q.answerIndex < 0 || q.answerIndex >= q.choices.length) return false;
      return true;
    })
    .map((q) => (q.type === "ox" ? { ...q, choices: ["O", "X"] } : q));
}
