# CI/CD and Shift-Left Security Framework

Building automated delivery pipelines that enforce code quality, security checks, and reliable rollbacks.

---

## 1. Shift-Left Security Gates

Security checks belong early in the development lifecycle, before code merges into the main branch.

```
 Developer Commit
        │
        ▼
┌────────────────────────────────────────────────────────┐
│ Pull Request Pipeline Checks                           │
├────────────────────────────────────────────────────────┤
│ 1. Linting & Formatting   (tflint, black, flake8)      │
│ 2. Security Static Scans  (tfsec, checkov)             │
│ 3. Container Scan         (trivy vulnerability scan)   │
│ 4. Unit & Contract Tests  (pytest, schema checks)      │
└───────────────────────┬────────────────────────────────┘
                        │
                        ▼ (Passes all checks)
┌────────────────────────────────────────────────────────┐
│ Plan & Review Phase                                    │
├────────────────────────────────────────────────────────┤
│ - Generate speculative Terraform plan                  │
│ - Post plan output directly on GitHub PR comments      │
│ - Require peer engineer approval                       │
└───────────────────────┬────────────────────────────────┘
                        │
                        ▼ (Merged to main)
┌────────────────────────────────────────────────────────┐
│ Automated Deployment & Verification                    │
├────────────────────────────────────────────────────────┤
│ - Terraform apply via locked service role              │
│ - Rolling task update with health verification         │
│ - Automated rollback on smoke test failure             │
└────────────────────────────────────────────────────────┘
```

I enforce static security scanning tools like `checkov` and `tfsec` directly inside GitHub Actions. If a pull request adds an open security group rule (`0.0.0.0/0` on port 22) or disables S3 bucket encryption, the build breaks immediately.

---

## 2. Zero-Downtime Deployment Strategies

Deploying updates during active business hours requires zero-downtime release strategies:

### Rolling Deployments
Update tasks incrementally behind the load balancer. The orchestrator starts a new container task, waits for ALB health checks to pass, routes traffic to the new task, and drains connections from the old task.

### Blue/Green Deployments
Stand up an identical environment ("Green") running the new code version alongside the current production environment ("Blue"). Run automated smoke tests against the Green environment. Once verified, switch DNS or load balancer listener targets instantly.

---

## 3. Automated Rollback Mechanisms

Deployment pipelines must detect degraded states and recover without manual operator intervention.

I configure automated rollback triggers based on three signals:
1. **Unhealthy Host Count:** If newly deployed containers fail target group health checks within three minutes, the deployment halts and rolls back to the previous stable task definition.
2. **Elevated 5xx Response Errors:** CloudWatch alarms track HTTP 5xx error spikes and trigger an automatic rollback when error rates exceed 1% over a two-minute window.
3. **Synthetic Endpoint Verification:** Post-deployment smoke test scripts query critical application routes. Any non-200 response triggers an immediate rollback.
