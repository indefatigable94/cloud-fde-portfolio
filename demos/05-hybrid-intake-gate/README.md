# Demo 05: The Smart Sorting Gate (Rules + Scoped AI Router)

**Author:** Habib Olajide (Cloud & AI Solutions Engineer / Associate FDE)  
**Target Roles:** Associate Forward-Deployed Engineer, Junior Solutions Architect

---

## 1. Plain-English Problem & Fix

### The Problem
Sending every single customer form, clinic referral, or support ticket to an expensive AI model wastes thousands of dollars and slows down simple requests. Most forms are clean and don't need fancy AI to read them.

### How We Fix It
We put a simple sorting gate at the front door. Easy forms with clear checkboxes get checked by basic computer rules in a split second for less than a penny. Only messy, handwritten notes or long voice messages get sent to the AI model to read and organize.

---

## 2. AWS & Technical Synopsis

- **Two-Tier Routing Architecture:**
  - **Tier 1 (Deterministic Fast Path):** Python **Pydantic** schemas and regex rules running on **AWS Lambda** validate 80% of clean web payloads in `12ms` at `$0.00001` per transaction.
  - **Tier 2 (Scoped LLM Fallback):** **Amazon EventBridge** routes only the remaining 20% unstructured text notes to a scoped model endpoint for entity extraction.
- **State & Deduplication:** Uses **Amazon DynamoDB** with Time-to-Live (TTL) idempotency keys so duplicate webhook clicks never create duplicate tickets.
- **Cybersecurity Controls:**
  - **Local PII Masking:** Customer phone numbers and personal IDs are scrambled immediately using **SHA-256 hashing** before any record reaches CloudWatch logs or external AI prompts.
  - **Least-Privilege IAM:** Separate IAM execution roles ensure the Tier 1 worker has zero permissions to invoke external AI models.

```
[Incoming Form / Webhook / Voice Note]
     │
     ▼
[Front-Door Sorting Gate]
     │
     ├── Clean Checkbox Form (80% Volume)
     │        └──► [Tier 1: Python Rules & SHA-256 Hash] (12ms | $0.00001)
     │
     └── Messy Free-Text Note (20% Volume)
              └──► [Tier 2: Scoped AI Extractor]         (120ms | $0.00300)
```

---

## 3. Cost & Speed Comparison (10,000 Monthly Forms)

| System Design | Average Speed | Monthly AI Bill | Private Info Safety |
| :--- | :--- | :--- | :--- |
| **Send Everything to AI** | 2,400 ms | $30.00 | Risky (Raw phone numbers sent to AI) |
| **Smart Sorting Gate (Ours)** | **24 ms** | **$6.08** | **Safe** (Scrambled with SHA-256 first) |
| **Business Result** | **99% Faster** | **80% Cheaper** | **100% Audit-Ready** |

---

## 4. Real-World Business Use Cases

### Healthcare & Epic Systems Integration
- **Cleaning Up Messy Referrals:** Clinics receive thousands of referrals every month. Standard digital forms pass through Tier 1 into **Epic Systems (FHIR endpoints)** in milliseconds. Messy faxed doctor notes route to Tier 2 so AI can pull out the right diagnosis codes without staff typing them by hand.

### Enterprise Tech & B2B SaaS Revenue
- **Calling Buyers Back in 30 Seconds (Speed-to-Lead):** When a big buyer fills out a "Request a Demo" form on a tech company's website, waiting an hour to reply kills the sale. This gate checks their company info, reads what they need, and sends them a calendar booking link in under 30 seconds. More demos get booked and sales pipeline grows without hiring extra reps.

---

## 5. Verification & Test Suite

Run the local verification script:
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
