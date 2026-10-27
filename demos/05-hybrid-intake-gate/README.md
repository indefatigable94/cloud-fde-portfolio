# Demo 05: Two-Tier Automated Intake Gate (Deterministic Rules + Scoped LLM Routing)

**Author:** Habib Olajide (Cloud & AI Solutions Engineer / Associate FDE)  
**Target Roles:** Associate Forward-Deployed Engineer, Junior Solutions Architect

---

## 1. Business Problem

Organizations often attempt to process all incoming data (customer support leads, incident tickets, clinic intake forms) using large language models. 

This introduces three critical operational failures:
1. **Unnecessary Token Costs:** Paying frontier model API rates for simple structured key-value forms.
2. **Latency Penalties:** Introducing 2 to 4 seconds of model latency to simple webhook endpoints.
3. **Privacy Risk:** Passing raw customer phone numbers and identifiers to external LLM providers without redaction.

---

## 2. Architecture & System Flow

```
[Incoming Payload (Webhook / Form / Raw Text)]
     │
     ▼
[Payload Inspection Gate]
     │
     ├── Clean Structured JSON (80% Volume)
     │        │
     │        ▼
     │   [Tier 1: Deterministic Fast Path]
     │   ├── Schema Validation (Pydantic / Regex)
     │   ├── SHA-256 PII Hashing (Phone / Identifiers)
     │   └── Cost: $0.00001 | Latency: < 15ms
     │        │
     │        ▼
     │   [Verified Production Record]
     │
     └── Messy Unstructured Text (20% Volume)
              │
              ▼
         [Tier 2: Scoped LLM Fallback Gate]
         ├── Dedicated Extraction Tool Schema
         ├── Context Redaction & Entity Normalization
         └── Cost: $0.00300 | Latency: ~120ms
              │
              ▼
         [Verified Production Record]
```

---

## 3. Cost & Latency Benchmark (10,000 Monthly Transactions)

| Architecture Pattern | Average Latency | Monthly API Spend | PII Leakage Risk |
| :--- | :--- | :--- | :--- |
| **All-LLM Architecture** | 2,400ms | $30.00 | High (Raw PII sent to cloud model) |
| **Two-Tier Hybrid Gate (This Build)** | **24ms** (Weighted) | **$6.08** (80% fast path) | **Zero** (SHA-256 hashed locally) |
| **Net Operational Advantage** | **99% Latency Reduction** | **80% Cost Reduction** | **Compliant Audit Trail** |

---

## 4. Operational Guardrails

- **Client-Side SHA-256 Hashing:** Raw phone numbers and personal identifiers are hashed immediately upon arrival. Plaintext PII is never stored in CloudWatch logs or passed to model contexts.
- **Fail-Closed Malformed Rejection:** Payloads lacking essential contact mechanisms or minimum descriptive text are routed to a dead-letter queue with specific error codes.
- **Cost Telemetry:** Emits custom CloudWatch metrics tracking the ratio of Tier 1 vs Tier 2 invocations to alert on abnormal spikes in unstructured traffic.

---

## 5. Verification & Tests

Run the demo suite:
```bash
python3 hybrid_intake_router.py
```

Expected output:
```text
--- Case 1: Structured Webhook ---
Route: DETERMINISTIC_FAST_PATH
Time: 0.04 ms | Cost: $ 1e-05
Phone Hash: e4121b5e2a993a17

--- Case 2: Unstructured Transcript ---
Route: LLM_FALLBACK_PATH
Extracted: Sarah Jenkins | Urgency: EMERGENCY
Time: 120.36 ms | Cost: $ 0.003
```
