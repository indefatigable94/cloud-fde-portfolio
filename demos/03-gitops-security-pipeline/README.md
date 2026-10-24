# Demo 3: GitOps CI/CD with Shift-Left Security & Rollback

Automated pipeline enforcing static security analysis, linting gates, and automated deployment rollbacks.

---

## 1. Business Problem

Manual infrastructure provisioning and unverified pull requests create severe security and reliability risks:
- Developers inadvertently opening SSH (port 22) to `0.0.0.0/0`.
- S3 buckets created without server-side encryption or access logging.
- Flawed container builds deployed to production without automated smoke testing.

---

## 2. Pipeline Architecture

```
 Pull Request Created
          │
          ▼
┌────────────────────────────────────────────────────────┐
│ Phase 1: Lint & Format Check                           │
│ - terraform fmt -check                                 │
│ - tflint                                               │
└────────────────────────┬───────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────┐
│ Phase 2: Static Security Analysis                      │
│ - tfsec (Checks for CIS benchmark violations)          │
│ - checkov (Enforces SOC 2 / HIPAA compliance rules)    │
└────────────────────────┬───────────────────────────────┘
                         │
                         ▼
┌────────────────────────────────────────────────────────┐
│ Phase 3: Container Vulnerability Scan                  │
│ - trivy fs --severity HIGH,CRITICAL                    │
└────────────────────────┬───────────────────────────────┘
                         │
                         ▼ (Passes all checks & approved)
┌────────────────────────────────────────────────────────┐
│ Phase 4: Deploy & Smoke Test Verification              │
│ - Automated deployment to staging                      │
│ - smoke_test.sh queries health endpoint                │
│ - Non-200 response triggers immediate rollback         │
└────────────────────────────────────────────────────────┘
```

---

## 3. Directory Contents

- `deploy.yml`: Production GitHub Actions workflow defining the lint, security scan, and rollback jobs.
- `scripts/smoke_test.sh`: Bash script that tests application endpoints and triggers a rollback exit code on failure.
