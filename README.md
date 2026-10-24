# Cloud Architecture and Forward-Deployed Engineering Portfolio

Practical cloud systems, client deployment patterns, and operational resilience playbooks.
Authored by Habib (Habeeb) Olajide.

---

## Overview

I build and support cloud systems that stay up, stay compliant, and recover fast when components fail.

My background spans emergency medical response, regulated healthcare compliance, and hands-on systems engineering. Working as an EMT and an onsite medical responder at Amazon taught me how to triage under pressure, follow protocols, and communicate clearly during incidents. My compliance background includes managing regulated client data with zero audit citations across New Jersey state reviews.

This portfolio demonstrates how I apply those operational principles to cloud infrastructure as an Associate Forward-Deployed Engineer (FDE) or Junior Cloud Architect.

---

## Core Focus Areas

```
┌─────────────────────────────────────────────────────────────┐
│                    Cloud Systems Focus                      │
├──────────────────────────────┬──────────────────────────────┤
│ 1. Downtime & Reliability    │ SLO/SLI budgets, multi-AZ,   │
│                              │ health checks, circuit break │
├──────────────────────────────┼──────────────────────────────┤
│ 2. Disaster Recovery (DR)    │ RTO/RPO targets, cross-region│
│                              │ replication, failover drills │
├──────────────────────────────┼──────────────────────────────┤
│ 3. Managed Environments      │ Container workloads (ECS),   │
│                              │ VPC isolation, least-privilege│
├──────────────────────────────┼──────────────────────────────┤
│ 4. CI/CD & Shift-Left Sec    │ Linting, automated security  │
│                              │ scans, rollbacks, GitOps     │
├──────────────────────────────┼──────────────────────────────┤
│ 5. Infrastructure as Code    │ Modular Terraform, state     │
│                              │ locking, drift prevention    │
└──────────────────────────────┴──────────────────────────────┘
```

---

## Portfolio Demos & MVPs

### 1. [Resilient Ingestion Gateway (Associate FDE Demo)](demos/01-resilient-ingestion-fde/)
- **Business Problem:** Client webhooks and third-party partner data drop during database maintenance or downstream outages.
- **Architecture:** API Gateway directly backed by AWS SQS with a Dead Letter Queue (DLQ), decoupled Lambda processing worker, and DynamoDB storage.
- **Operational Outcome:** Zero dropped transactions during downstream outages. Messages queue automatically and process cleanly once the database recovers.

### 2. [Regulated Multi-AZ Platform & Disaster Recovery (Cloud Architect Demo)](demos/02-regulated-multi-az-platform/)
- **Business Problem:** Regulated applications need 99.9% availability, isolated network tiers, and verified disaster recovery procedures.
- **Architecture:** Terraform deployment of a multi-AZ VPC, Application Load Balancer, containerized ECS Fargate tasks across two availability zones, and an RDS PostgreSQL instance with multi-AZ standby and automated cross-region snapshot replication.
- **Operational Outcome:** Tested 15-minute Recovery Time Objective (RTO) and 5-minute Recovery Point Objective (RPO) with documented failover runbooks.

### 3. [GitOps CI/CD with Shift-Left Security & Rollback](demos/03-gitops-security-pipeline/)
- **Business Problem:** Misconfigured security groups, hardcoded credentials, and broken builds reach production environments without automated gates.
- **Architecture:** GitHub Actions pipeline running Terraform validation (`terraform fmt`, `tflint`), static security scanning (`tfsec`, `checkov`), container image vulnerability checks (`trivy`), zero-downtime rolling deployment, and automated health check verification.
- **Operational Outcome:** High-risk pull requests fail early before reaching staging or production.

---

## Operational Frameworks

- [Approach & Field Philosophy](docs/approach-and-voice.md): How I handle client deployments, incident triage, and technical trade-offs.
- [Downtime & High Availability](frameworks/downtime-and-availability.md): Availability tiers, error budgets, and health check designs.
- [Disaster Recovery](frameworks/disaster-recovery.md): Real-world RTO and RPO strategies from pilot light to warm standby.
- [Managed Environments](frameworks/managed-environments.md): Secure VPC architecture, container orchestration, and secret management.
- [CI/CD Pipelines](frameworks/ci-cd-pipelines.md): Automated quality gates, security policies, and rollback triggers.
- [Infrastructure as Code](frameworks/infrastructure-as-code.md): Clean Terraform conventions, state safety, and drift detection.

---

## Background & Certifications

- **Certifications:** CompTIA Security+, UPenn Cybersecurity Graduate.
- **Regulated Operations:** 7+ years managing clinical compliance, state audits (100% audit pass rate), and HIPAA data controls.
- **Incident Response:** Experienced in high-volume emergency response and structured incident triage at Amazon and New Jersey EMS services.
