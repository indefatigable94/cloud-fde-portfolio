# Demo 2: Regulated Multi-AZ Platform and Disaster Recovery

High availability infrastructure deployment with automated multi-region backup replication and documented failover drills.

---

## 1. Business Problem

Healthcare and financial workloads require strict availability and compliance controls:
- **Zero Public Database Exposure:** Databases cannot have public IP addresses or direct internet routes.
- **High Availability Target:** Maintain 99.9% uptime during single-zone data center disruptions.
- **Disaster Recovery Target:** Achieve an RTO under 15 minutes and an RPO under 5 minutes during a regional outage.

---

## 2. Architecture Diagram

```
 Internet
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ Application Load Balancer (ALB)                             │
│ - us-east-1a Public Subnet     │ - us-east-1b Public Subnet │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ AWS ECS Fargate Cluster                                     │
│ - us-east-1a App Subnet        │ - us-east-1b App Subnet    │
│ - Minimum healthy tasks: 2     │ - Auto-recovery enabled    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Amazon RDS PostgreSQL Multi-AZ                              │
│ - Primary: us-east-1a Private  │ - Standby: us-east-1b      │
│ - Synchronous replication      │ - Automated failover       │
│                                │                            │
│ ──► Automated Cross-Region Snapshot Replication ──► us-west-2│
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Key Design Decisions

1. **Strict 3-Tier Network Isolation:** Public subnets host only load balancers. Application tasks live in private subnets with outbound-only NAT access. Databases live in isolated subnets with zero internet routing.
2. **Synchronous Multi-AZ Database:** Amazon RDS PostgreSQL maintains a synchronous standby instance in a second availability zone. If the primary zone fails, failover completes automatically within 60 to 120 seconds.
3. **Cross-Region Replication:** Automated database snapshots replicate to `us-west-2` every hour. This guarantees an RPO under 60 minutes for regional disasters, and 5 minutes during single-zone disruptions.

---

## 4. Disaster Recovery Drill Script

The included shell script `dr-failover-drill.sh` executes a simulated zone outage:
1. Triggers manual RDS reboot with failover to verify standby promotion.
2. Runs synthetic HTTP health checks against the Application Load Balancer during failover.
3. Logs total recovery time and error counts to verify RTO compliance.
