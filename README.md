# Cloud Architecture & Forward-Deployed Engineering Portfolio

Practical cloud systems, client deployment playbooks, and safe AI workflows.  
Authored by Habib Olajide.

---

## Overview

I build cloud and AI systems that stay up, pass strict audits, and recover fast when parts fail.

My background spans emergency medical response, regulated healthcare compliance, and hands-on systems engineering. Working as an EMT and an onsite medical responder at Amazon taught me how to triage under pressure, follow protocols, and communicate clearly when things break. My compliance background includes managing regulated healthcare records with a 100% audit pass rate and zero state citations across New Jersey reviews.

This portfolio shows how I apply those field habits to cloud architecture and AI engineering as an Associate Forward-Deployed Engineer (FDE) or Junior Solutions Architect.

---

## Core Focus Areas

```
┌─────────────────────────────────────────────────────────────┐
│                    Cloud Systems Focus                      │
├──────────────────────────────┬──────────────────────────────┤
│ 1. Downtime & Reliability    │ Multi-AZ design, SQS queues, │
│                              │ health checks, circuit break │
├──────────────────────────────┼──────────────────────────────┤
│ 2. Disaster Recovery (DR)    │ RTO/RPO targets, cross-region│
│                              │ backups, failover drills     │
├──────────────────────────────┼──────────────────────────────┤
│ 3. Managed Instances         │ ECS Fargate, RDS Multi-AZ,   │
│                              │ SSM Session Manager (no SSH) │
├──────────────────────────────┼──────────────────────────────┤
│ 4. Security & GRC Controls   │ IAM least-privilege, KMS,    │
│                              │ SHA-256 PII masking, WAF     │
├──────────────────────────────┼──────────────────────────────┤
│ 5. Infrastructure as Code    │ Modular Terraform, state     │
│                              │ locking, drift prevention    │
└──────────────────────────────┴──────────────────────────────┘
```

---

## Portfolio Demos & Real-World Use Cases

### 1. [The Rulebook Search Tool (Grounded Enterprise RAG)](demos/04-regulated-policy-rag/)
- **Plain-English Problem:** Workers waste hours digging through 400-page policy binders to answer compliance questions. If they ask regular ChatGPT, it makes up fake rules and gets the company fined.
- **How We Fix It:** We build a search tool that only reads the company's real policy documents. Every answer must include the exact page and section code. If the system can't find a verified rule match, it stays quiet and flags a human manager for help.
- **AWS & Technical Synopsis:**
  - **Compute & Storage:** Runs on managed **AWS ECS Fargate** containers with **Amazon RDS for PostgreSQL (Multi-AZ)** and `pgvector` for hybrid keyword and vector search.
  - **Retrieval Gate:** Enforces a strict `0.82` confidence floor and verifies that cited section codes exist in the source database before returning an answer.
  - **Security Controls:** Uses **AWS PrivateLink** so prompts stay inside the private VPC network, **AWS KMS** encryption at rest, and role-based access control (RBAC) by department.
- **Industry Applications:**
  - **Healthcare (Epic Systems):** Reads insurance rules and patient chart data via Epic APIs to draft prior-authorization forms with exact policy numbers attached, cutting claim denials.
  - **Tech & SaaS Companies:** Auto-completes 90% of enterprise customer security questionnaires using verified SOC 2 and security docs, helping sales teams close six-figure deals weeks faster.

---

### 2. [The After-Hours Phone Helper & Resilient Queue](demos/01-resilient-ingestion-fde/)
- **Plain-English Problem:** When customers or patients call at night and hit voicemail, they hang up and call a competitor. Also, if a company's database restarts during a busy hour, incoming web forms and call notes get dropped and lost forever.
- **How We Fix It:** An AI phone helper answers on the first ring and asks four simple questions: who you are, where you are, what broke, and how urgent it is. It places those answers into a digital waiting line (a queue) so zero calls are ever lost, even if the main database is down for maintenance. If a caller has a real life-safety emergency, it transfers the call straight to a live person right away.
- **AWS & Technical Synopsis:**
  - **Architecture:** **Retell AI** voice webhooks hit **Amazon API Gateway**, which writes directly to **Amazon SQS** backed by an **S3 Dead-Letter Queue (DLQ)**. A decoupled **AWS Lambda** worker writes validated records to **Amazon DynamoDB**.
  - **Security Controls:** Validates incoming webhooks with **HMAC-SHA256** signatures, stores API keys in **AWS Secrets Manager** with 30-day rotation, and protects the endpoint with **AWS WAF**.
- **Industry Applications:**
  - **Healthcare (Epic Systems):** Takes midnight patient triage calls, summarizes symptoms into a clean **SOAP note** (Subjective, Objective, Assessment, Plan), and drops it into the nurse's Epic inbox while routing chest-pain calls straight to the emergency desk.
  - **Tech & Home Services:** Captures 100% of after-hours emergency service requests and buffers customer webhook traffic during server outages so the business never loses revenue.

---

### 3. [The Smart Sorting Gate (Rules + Scoped AI Router)](demos/05-hybrid-intake-gate/)
- **Plain-English Problem:** Sending every single customer form or support ticket to a large AI model wastes thousands of dollars and slows down simple requests. Most forms are clean and don't need heavy AI.
- **How We Fix It:** We put a fast sorting gate at the front door. Clean forms with standard checkboxes get checked by basic computer rules in a split second for less than a penny. Only messy, handwritten notes or long voice transcripts get sent to the AI model to read and organize.
- **AWS & Technical Synopsis:**
  - **Two-Tier Routing:** Tier 1 runs Python **Pydantic** and regex validation on **AWS Lambda**, clearing 80% of standard traffic in `12ms` at `$0.00001` per record. Tier 2 uses **Amazon EventBridge** to route the 20% unstructured text exceptions to a scoped LLM endpoint.
  - **Security Controls:** Scrambles customer phone numbers and IDs locally using **SHA-256 hashing** before anything touches CloudWatch logs or external AI models. Enforces strict **IAM least-privilege** roles per tier.
- **Industry Applications:**
  - **Healthcare (Epic Systems):** Checks standard clinic referral forms instantly and only uses AI to pull billing codes from messy faxed doctor notes before saving to Epic.
  - **Tech & SaaS Companies:** Qualifies inbound "Request a Demo" leads and sends a calendar booking link in under 30 seconds while cutting monthly AI token bills by 80%.

---

### 4. [Regulated Multi-AZ Platform & Disaster Recovery](demos/02-regulated-multi-az-platform/)
- **Plain-English Problem:** If a company runs its app in only one data center and the power goes out in that building, the whole business goes offline.
- **How We Fix It:** We spread the servers across two separate data centers at the same time and keep a live backup of the database ready to take over automatically if the main one fails.
- **AWS & Technical Synopsis:**
  - **Architecture:** Modular **Terraform** deployment of a Multi-AZ VPC, Application Load Balancer, **ECS Fargate** containers across two availability zones, and **RDS PostgreSQL** with Multi-AZ standby and cross-region snapshot copies.
  - **Managed Instances:** Any jump hosts or support nodes use **AWS Systems Manager (SSM) Session Manager** with zero open SSH ports.
  - **Verified Outcome:** Tested 15-minute Recovery Time Objective (RTO) and 5-minute Recovery Point Objective (RPO).

---

### 5. [Automated Security Checks on Every Code Change (GitOps CI/CD)](demos/03-gitops-security-pipeline/)
- **Plain-English Problem:** Engineers sometimes accidentally leave secret passwords in their code or open the wrong network doors when rushing an update.
- **How We Fix It:** Every time someone tries to save new code, an automated robot checks it for mistakes and locked doors before it is allowed to go live.
- **AWS & Technical Synopsis:**
  - **Pipeline:** **GitHub Actions** workflow running Terraform formatting (`terraform fmt`, `tflint`), infrastructure security scanners (`tfsec`, `checkov`), and container vulnerability checks (`trivy`).
  - **Verified Outcome:** Blocks unsafe code changes automatically and rolls back failed deployments without human intervention.

---

## Operational Playbooks

- [Approach & Field Philosophy](docs/approach-and-voice.md): How I handle client deployments, incident triage, and technical trade-offs.
- [Downtime & High Availability](frameworks/downtime-and-availability.md): Availability tiers, error budgets, and health check designs.
- [Disaster Recovery](frameworks/disaster-recovery.md): Real-world RTO and RPO strategies from pilot light to warm standby.
- [Managed Environments](frameworks/managed-environments.md): Secure VPC architecture, container orchestration, and secret management.
- [CI/CD Pipelines](frameworks/ci-cd-pipelines.md): Automated quality gates, security policies, and rollback triggers.
- [Infrastructure as Code](frameworks/infrastructure-as-code.md): Clean Terraform conventions, state safety, and drift detection.

---

## Background & Certifications

- **Certifications:** CompTIA Security+, UPenn Cybersecurity Bootcamp Graduate.
- **Regulated Operations:** 7+ years managing clinical compliance, state audits (100% audit pass rate, zero citations), and HIPAA privacy controls.
- **Incident Response:** Frontline emergency medical technician (EMT) and Onsite Medical Representative at Amazon fulfillment operations.
