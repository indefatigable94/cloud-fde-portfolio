# Managed Environments Framework

Architecture patterns for secure, maintainable cloud environments.

---

## 1. Network Segmentation and VPC Design

Production environments require strict network boundaries between external traffic, application compute, and persistence layers.

```
 Internet
    │
    ▼
┌────────────────────────────────────────────────────────┐
│ Public Subnet (us-east-1a / us-east-1b)               │
│ - Internet Gateway                                    │
│ - Application Load Balancer (ALB)                     │
│ - NAT Gateways (Outbound only)                        │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ Private App Subnet (us-east-1a / us-east-1b)           │
│ - AWS ECS Fargate Tasks / EKS Nodes                   │
│ - No public IP addresses                              │
│ - Inbound traffic restricted to ALB Security Group    │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│ Isolated Data Subnet (us-east-1a / us-east-1b)         │
│ - Amazon RDS PostgreSQL Multi-AZ                      │
│ - No internet access (No NAT route)                   │
│ - Inbound restricted exclusively to App Security Group│
└────────────────────────────────────────────────────────┘
```

I place databases in private subnets with no direct internet route. Inbound connections must originate from explicit security group IDs assigned to application compute nodes.

---

## 2. Containerized Workloads on Managed Compute

Managing raw EC2 instances introduces maintenance overhead for patching operating systems and updating runtimes.

For standard web and API workloads, I deploy containerized tasks on AWS ECS Fargate. Fargate manages the underlying servers, provisions capacity on demand, and isolates containers at the virtualization level.

### Operational Benefits:
- **No Patching Overhead:** AWS manages the underlying operating system and hypervisor patches.
- **Fast Scaling:** Tasks spin up within seconds in response to CPU or memory alarms.
- **Task-Level IAM Roles:** Each container task receives its own fine-grained IAM role rather than inheriting broad EC2 instance permissions.

---

## 3. Secret Management and Least Privilege

Hardcoding API tokens, database credentials, or private keys inside container images or Git repositories creates major security vulnerabilities.

I enforce three secret management standards:
1. **AWS Secrets Manager & SSM Parameter Store:** Store credentials centrally with automatic KMS envelope encryption.
2. **Runtime Secret Injection:** Inject secrets into container environment variables at task launch via AWS IAM task roles.
3. **IAM Least Privilege:** Restrict policies strictly to the required actions and resource ARNs. Avoid wildcard (`*`) permissions across all production roles.
