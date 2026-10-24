#!/usr/bin/env bash
# ==============================================================================
# Post-Deployment Smoke Test & Health Check
# Queries deployment endpoint; exits non-zero on failure to trigger CI/CD rollback.
# ==============================================================================

set -euo pipefail

TARGET_URL="${1:-http://localhost:8080/health}"
MAX_RETRIES=5
SLEEP_INTERVAL=5

echo "[*] Starting post-deployment smoke test against: ${TARGET_URL}"

for i in $(seq 1 "${MAX_RETRIES}"); do
  echo "    Attempt ${i}/${MAX_RETRIES}: Checking endpoint..."
  
  # Fetch HTTP status code with 5-second timeout
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${TARGET_URL}" || echo "000")

  if [ "${HTTP_STATUS}" = "200" ]; then
    echo "[✓] Endpoint returned HTTP 200 OK. Verification passed."
    exit 0
  fi

  echo "    [!] Received HTTP ${HTTP_STATUS}. Retrying in ${SLEEP_INTERVAL} seconds..."
  sleep "${SLEEP_INTERVAL}"
done

echo "[✗] ERROR: Target failed to return HTTP 200 within ${MAX_RETRIES} attempts."
echo "[*] Triggering automated pipeline rollback."
exit 1
