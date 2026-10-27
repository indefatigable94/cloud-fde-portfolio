# Demo 04: The Rulebook Search Tool (Grounded Enterprise RAG)

**Author:** Habib Olajide (Cloud & AI Solutions Engineer / Associate FDE)  
**Target Roles:** Associate Forward-Deployed Engineer, Junior Solutions Architect

---

## 1. Plain-English Problem & Fix

### The Problem
Workers in healthcare and regulated companies waste hours every week digging through 400-page policy binders to answer simple compliance questions. If they ask regular ChatGPT, it makes up fake rules and gets the company fined during state inspections.

### How We Fix It
We build a search tool that only reads the company's real rulebooks. It has to show the exact page and section code for every answer it gives. If it can't find a verified rule match in the binder, it stays quiet and asks a human compliance manager to step in.

---

## 2. AWS & Technical Synopsis

- **Managed Compute & Database:** Deployed on **AWS ECS Fargate** (serverless containers with zero OS patching) connected to **Amazon RDS for PostgreSQL (Multi-AZ)** running `pgvector`.
- **Hybrid Search Engine:** Combines exact keyword matching (30% weight) with vector similarity embeddings (70% weight) filtered by state jurisdiction and department metadata.
- **Deterministic Citation Gate:** Every response is checked against two rules before the user sees it:
  1. Similarity confidence must be `0.82` or higher.
  2. Every cited policy code must exist inside the retrieved source chunks.
- **Cybersecurity Controls:**
  - **Private Network Routing:** Uses **AWS PrivateLink** so regulatory queries and model responses stay inside the private VPC and never cross the public internet.
  - **Encryption & Access:** Data is encrypted at rest using **AWS KMS** customer-managed keys. Role-based access control (RBAC) ensures staff only query documents approved for their role.

```
[Staff Question]
     │
     ▼
[Department & State Filter] ──► (e.g., State = NJ, Agency = DHS-DDD)
     │
     ▼
[Hybrid Search (RDS pgvector)] ──► 70% Vector Match + 30% Keyword Match
     │
     ▼
[Citation Verification Gate]
     ├── Score >= 0.82 AND Section Code Verified? ──► Return Grounded Answer
     └── Below 0.82 OR Unverified Code?          ──► Block & Alert Compliance Officer
```

---

## 3. Real-World Business Use Cases

### Healthcare & Epic Systems Integration
- **Faster Insurance Approvals (Prior Auth):** Insurance companies deny patient care when forms miss a specific rule code. This tool reads the payer's rulebook, pulls patient chart facts from **Epic Systems (FHIR APIs)**, and drafts the approval form with the exact policy code attached. Clinics get paid faster and patients get care on time.
- **Zero-Citation State Audits:** Helps clinical support coordinators verify documentation rules in seconds during unannounced state inspections.

### Enterprise Tech & B2B SaaS Revenue
- **Closing Sales Deals Faster:** Big software deals often stall for 6 weeks because the buyer's security team sends over a 200-question security spreadsheet. This tool auto-completes 90% of those questions in 10 minutes using verified SOC 2 reports and security docs, helping sales teams close revenue weeks faster.

---

## 4. Verification & Test Suite

Run the local verification script:
```bash
python3 policy_retrieval_guard.py
```

Expected output:
```text
Test 1 Result: VERIFIED_AUDIT_READY | Confidence: 1.0
Test 2 Result: REJECTED_UNGROUNDED_CITATION | Audit: Citation 'N.J.A.C. 99:99X-FAKE' not found in authoritative retrieved context. Model output blocked.
```
