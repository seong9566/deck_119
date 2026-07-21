'use strict';

const DISCORD_WEBHOOK_URL = process.env.DISCORD_WEBHOOK_URL;

async function notifyDiscord(embed) {
  if (!DISCORD_WEBHOOK_URL) return;

  try {
    const response = await fetch(DISCORD_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ embeds: [embed] }),
    });
    if (!response.ok) {
      console.error(`[discord] webhook 실패: HTTP ${response.status}`);
    }
  } catch (e) {
    console.error(`[discord] webhook 실패: ${e.message}`);
  }
}

module.exports = { notifyDiscord };
