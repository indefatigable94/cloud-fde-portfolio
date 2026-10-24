# Downtime and High Availability Framework

Practical strategies for minimizing downtime and managing service availability.

---

## 1. Availability Tiers and Real-World Math

Availability numbers sound simple until you calculate the actual allowable downtime.

| Target SLA | Allowable Downtime / Year | Allowable Downtime / Month | Typical Architecture |
| :--- | :--- | :--- | :--- |
| **99.0% (Two Nines)** | 3.65 days | 7.31 hours | Single AZ instance, manual backups |
| **99.9% (Three Nines)** | 8.77 hours | 43.83 minutes | Multi-AZ compute, managed database with standby |
| **99.95%** | 4.38 hours | 21.92 minutes | Multi-AZ auto-scaling, health checks, automated failover |
| **99.99% (Four Nines)** | 52.60 minutes | 4.38 minutes | Multi-region active-active or fast warm standby |

Every additional nine increases cloud cost and engineering complexity. I evaluate customer workloads against their actual business downtime cost before picking an architecture.

---

## 2. Key Reliability Metrics

We measure system health using three core metrics:

```
    Incident Starts           Service Restored
           │                         │
           ▼                         ▼
   ┌───────┬─────────────────────────┬───────────────┐
   │ Normal│    Outage / Recovery    │ Normal Oper.  │
   │ Oper. │                         │               │
   └───────┴─────────────────────────┴───────────────┘
           ▲                         ▲
           │◄───────────────────────►│
                      MTTR
```

- **MTTD (Mean Time to Detect):** How fast alarms alert the team after a failure begins. Good health checks and synthetic monitors keep MTTD under two minutes.
- **MTTR (Mean Time to Recover):** The time required to restore customer service. Automated health check restarts and database failovers reduce MTTR from hours to minutes.
- **MTBF (Mean Time Between Failures):** The reliability lifespan of system components between incidents.

---

## 3. Core High Availability Patterns

### Multi-Availability Zone Deployments
Never deploy critical production workloads into a single data center. I configure Application Load Balancers (ALBs) to distribute traffic across at least two distinct Availability Zones within an AWS region.

### Deep Health Checks
A shallow health check returns HTTP 200 if the web server process responds. A deep health check verifies database connectivity, cache reachability, and disk space. If a worker node cannot reach the database, the load balancer stops routing traffic to that node immediately.

### Circuit Breakers and Backoff
When a downstream service degrades, cascading retries can crash the caller. I implement exponential backoff with jitter and circuit breakers to give struggling services room to recover.
