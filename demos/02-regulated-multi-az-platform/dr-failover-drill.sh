#!/usr/bin/env bash
# ==============================================================================
# Disaster Recovery Drill: RDS Multi-AZ Simulated Failover
# Measures Recovery Time Objective (RTO) and availability during failover.
# ==============================================================================

set -euo pipefail

DB_IDENTIFIER="${1:-prod-postgres-db}"
REGION="${AWS_REGION:-us-east-1}"

echo "[*] Starting Disaster Recovery Drill for RDS instance: ${DB_IDENTIFIER}"
echo "[*] AWS Region: ${REGION}"

START_TIME=$(date +%s)

# 1. Trigger RDS Failover
echo "[*] Triggering RDS reboot with failover to standby availability zone..."
aws rds reboot-db-instance \
  --db-instance-identifier "${DB_IDENTIFIER}" \
  --force-failover \
  --region "${REGION}" > /dev/null

echo "[+] Failover signal sent. Monitoring database status..."

# 2. Poll until status returns to 'available'
while true; do
  STATUS=$(aws rds describe-db-instances \
    --db-instance-identifier "${DB_IDENTIFIER}" \
    --region "${REGION}" \
    --query "DBInstances[0].DBInstanceStatus" \
    --output text)

  CURRENT_TIME=$(date +%s)
  ELAPSED=$((CURRENT_TIME - START_TIME))

  echo "    [+${ELAPSED}s] Current status: ${STATUS}"

  if [ "${STATUS}" = "available" ] && [ "${ELAPSED}" -gt 15 ]; then
    echo "[✓] Database failover complete and instance is available."
    break
  fi

  sleep 5
done

END_TIME=$(date +%s)
TOTAL_RTO=$((END_TIME - START_TIME))

echo "=============================================================================="
echo "DRILL SUMMARY"
echo "Target DB:   ${DB_IDENTIFIER}"
echo "Total RTO:   ${TOTAL_RTO} seconds ($((TOTAL_RTO / 60))m $((TOTAL_RTO % 60))s)"
echo "RTO SLA:     15 minutes (900 seconds)"
if [ "${TOTAL_RTO}" -le 900 ]; then
  echo "VERDICT:     PASSED (Met RTO target)"
else
  echo "VERDICT:     FAILED (Exceeded RTO target)"
fi
echo "=============================================================================="
