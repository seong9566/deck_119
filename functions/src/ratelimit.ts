import { getFirestore, FieldValue } from "firebase-admin/firestore";

/// 일일 생성 한도(방어적 상한). installId(기기 설치 id) 기준 카운터.
/// 트랜잭션으로 원자적 증가. 한도 초과면 -1(증가 안 함), 아니면 남은 횟수 반환.
/// 주의: 날짜 경계는 UTC. 기기 재설치 시 초기화될 수 있음 — 1명 배포 스코프에서 수용.
export async function checkAndIncrement(
  installId: string,
  dailyLimit: number,
): Promise<number> {
  const db = getFirestore();
  const ref = db.collection("gen_rate_limits").doc(installId);
  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD (UTC)

  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    let count = 0;
    if (snap.exists && snap.get("date") === today) {
      count = (snap.get("count") as number) ?? 0;
    }
    if (count >= dailyLimit) return -1;
    tx.set(ref, {
      date: today,
      count: count + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return dailyLimit - (count + 1);
  });
}
