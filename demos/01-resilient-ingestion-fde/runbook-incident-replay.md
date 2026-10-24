# Runbook: Dead Letter Queue Inspection and Redrive

Operational procedures for triaging failed events and replaying messages after downstream incident resolution.

---

## 1. Trigger Condition

This runbook activates when CloudWatch Alarm `DLQ-Messages-Visible` triggers with `ApproximateNumberOfMessagesVisible > 0`.

---

## 2. Step 1: Inspect Failed Messages in the DLQ

Do not delete or bulk-replay messages without inspecting the error cause first.

Query the DLQ using the AWS CLI to inspect the payload and attributes:

```bash
# Retrieve message attributes from the DLQ
aws sqs receive-message \
  --queue-url "$DLQ_URL" \
  --attribute-names All \
  --message-attribute-names All \
  --max-number-of-messages 5 \
  --visibility-timeout 30
```

Check the CloudWatch Logs for the Lambda worker to identify the exact exception:

```bash
# Filter CloudWatch logs for recent errors
aws logs filter-log-events \
  --log-group-name "/aws/lambda/prod-event-ingestion-worker" \
  --filter-pattern "ERROR" \
  --start-time $(date -v-1H +%s000)
```

Common root causes:
- Downstream database throttling or connection pool saturation.
- Schema changes in third-party webhook payloads without updated parser logic.
- Malformed JSON payloads missing required identifier keys.

---

## 3. Step 2: Fix Downstream Blocker

Before triggering a redrive, verify downstream services can accept traffic:
1. Confirm the target database or table is accessible and responsive.
2. If the failure stemmed from a parser bug, deploy the updated Lambda worker code first.
3. Verify test events process cleanly through the worker before replaying bulk production traffic.

---

## 4. Step 3: Execute SQS Redrive

Once downstream services are healthy, initiate an automated SQS redrive to move messages back to the primary queue:

```bash
# Start SQS DLQ redrive task
aws sqs start-message-move-task \
  --source-arn "$DLQ_ARN" \
  --destination-arn "$PRIMARY_QUEUE_ARN"
```

Monitor the move task progress:

```bash
# Check redrive task status
aws sqs list-message-move-tasks \
  --source-arn "$DLQ_ARN"
```

---

## 5. Step 4: Verification and Incident Closure

1. Verify that `ApproximateNumberOfMessagesVisible` on the DLQ returns to zero.
2. Confirm new rows appear in the DynamoDB table with `status = "PROCESSED"`.
3. Check CloudWatch metrics for `NumberOfErrors = 0`.
4. Document the root cause, message count, and recovery timeline in the incident log.
