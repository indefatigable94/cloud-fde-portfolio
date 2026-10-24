# Demo 1: Resilient Ingestion Gateway (Associate FDE)

Decoupled event ingestion pipeline designed to prevent data loss during downstream outages.

---

## 1. Business Problem

Client applications and third-party partners send critical webhooks (such as payment notifications, order events, or clinical updates) into an API endpoint.

When downstream databases undergo maintenance, hit connection limits, or experience temporary outages, synchronous API endpoints return HTTP 500 or 504 errors. Clients drop transactions, creating manual data recovery work and customer support tickets.

---

## 2. Solution Architecture

```
 External Webhook
        │ (HTTP POST)
        ▼
┌──────────────────────────────┐
│ Amazon API Gateway           │
│ (Direct AWS Service Proxy)   │
└──────────────┬───────────────┘
               │ (Direct Queue Enqueue)
               ▼
┌──────────────────────────────┐
│ Amazon SQS Primary Queue     │
│ (Standard or FIFO)           │
└───────┬──────────────┬───────┘
        │              │ (MaxReceiveCount > 3)
        │              ▼
        │      ┌──────────────────────────────┐
        │      │ Amazon SQS Dead Letter Queue │
        │      │ (DLQ for Poison Messages)    │
        │      └──────────────────────────────┘
        ▼
┌──────────────────────────────┐
│ AWS Lambda Worker            │
│ (Batch size: 10, retries: 3) │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Amazon DynamoDB Table        │
│ (Encrypted at rest with KMS) │
└──────────────────────────────┘
```

### Key Technical Decisions:
1. **Direct API Gateway to SQS Integration:** API Gateway acts as a direct proxy to Amazon SQS without an intermediate compute layer. This eliminates cold starts and accepts inbound traffic even if downstream workers are paused.
2. **Dead Letter Queue (DLQ):** Messages that fail processing three consecutive times move to a dead-letter queue. This isolates malformed messages without blocking valid traffic.
3. **At-Rest KMS Encryption:** All queues and database tables use customer-managed AWS KMS keys for audit compliance.

---

## 3. Directory Contents

- `main.tf`: Complete Terraform configuration defining API Gateway, SQS queues, IAM roles, Lambda function, and DynamoDB.
- `variables.tf`: Configurable inputs for environment name, retention periods, and batch sizes.
- `outputs.tf`: API Gateway endpoint URL and queue ARNs.
- `lambda/worker.py`: Python worker script handling message parsing, idempotency, and database writes.
- `runbook-incident-replay.md`: Step-by-step operator guide for inspecting DLQ messages and replaying them after an outage.
