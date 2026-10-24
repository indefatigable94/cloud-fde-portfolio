# Disaster Recovery Framework

Strategies, recovery objectives, and failover runbooks for production workloads.

---

## 1. RTO and RPO Definitions

Disaster recovery design starts with two specific business numbers:

```
               Last Good Backup       Disaster Hits       Service Restored
                      │                     │                     │
                      ▼                     ▼                     ▼
              ────────┬─────────────────────┬─────────────────────┬────────
                      │◄───────────────────►│◄───────────────────►│
                                RPO                       RTO
                         (Data Loss Window)        (Downtime Window)
```

- **RPO (Recovery Point Objective):** The maximum acceptable data loss measured in time. An RPO of 15 minutes means the business accepts losing up to 15 minutes of transactional data.
- **RTO (Recovery Time Objective):** The maximum acceptable downtime before service is restored. An RTO of 1 hour means the system must resume processing within 60 minutes of an outage.

---

## 2. Disaster Recovery Strategies

I structure disaster recovery strategies into four distinct tiers based on cost and recovery speed:

```
Cost & Complexity ▲
                  │                                   [Active-Active]
                  │                                   RTO/RPO: < 1 min
                  │
                  │                        [Warm Standby]
                  │                        RTO/RPO: Minutes
                  │
                  │             [Pilot Light]
                  │             RTO: ~15 mins, RPO: Low
                  │
                  │  [Backup & Restore]
                  │  RTO: Hours, RPO: Hours
                  └──────────────────────────────────────────────► Recovery Speed
```

### Tier 1: Backup and Restore
Data gets snapshotted and exported to Amazon S3, with cross-region replication enabled. Low infrastructure cost during normal operations. Recovery takes several hours because new compute instances and databases must be provisioned from scratch.

### Tier 2: Pilot Light
Core data elements (such as databases and object stores) replicate continuously to a secondary region. Compute resources remain turned off or scaled to zero. During a disaster, automated scripts scale up compute instances and attach to the replicated database.

### Tier 3: Warm Standby
A scaled-down version of the full production stack runs continuously in the secondary region. The standby environment handles synthetic tests and minimal background jobs. Failover takes minutes by updating DNS records or load balancer routing.

### Tier 4: Multi-Region Active-Active
Production traffic serves simultaneously from two or more AWS regions. Latency-based or geolocation routing directs traffic to the nearest healthy region. Provides the lowest RTO and RPO, with higher operational overhead and infrastructure expense.

---

## 3. The DR Runbook Protocol

Untested disaster recovery plans fail during actual emergencies.

A production-ready DR plan includes a written runbook with four clear sections:
1. **Trigger Criteria:** Specific alarm thresholds required before declaring a regional failover.
2. **Authority:** The named roles authorized to trigger the recovery procedure.
3. **Execution Commands:** Exact CLI scripts and Terraform commands to promote read replicas and redirect DNS traffic.
4. **Validation Tests:** Health check endpoints and data integrity tests required before opening traffic to customers.
