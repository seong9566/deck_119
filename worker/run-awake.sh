#!/bin/sh
# 맥북 슬립 방지(caffeinate) + 워커가 죽으면 자동 재시작.
# 사용: npm run start:awake  (= caffeinate -s sh run-awake.sh)
cd "$(dirname "$0")"
while true; do
  node index.js
  echo "[restart] 워커가 종료됨 → 2초 후 재시작"
  sleep 2
done
