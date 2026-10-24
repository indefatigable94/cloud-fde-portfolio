# Infrastructure as Code (IaC) Framework

Standards for managing infrastructure using modular Terraform, remote state locking, and drift detection.

---

## 1. Remote State Management and Locking

Local Terraform state files risk corruption and credential leaks.

Production Terraform configurations require a remote backend with two safeguards:
- **Amazon S3 Backend:** Stores the `terraform.tfstate` file centrally with server-side encryption enabled (AES-256 or AWS KMS) and versioning turned on.
- **Amazon DynamoDB State Locking:** Prevents concurrent runs from executing conflicting changes against the same environment simultaneously.

```hcl
terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "production-terraform-state-backend"
    key            = "core-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

---

## 2. Modular Architecture and Separation of Concerns

Monolithic Terraform codebases create high blast radiuses. A small typo in a monitoring tag can accidentally trigger a database recreation.

I separate infrastructure into decoupled root modules:

```
terraform/
├── 01-networking/     # VPC, Subnets, Internet Gateways, NAT Gateways
├── 02-security/       # IAM Roles, Policies, Security Groups, KMS Keys
├── 03-persistence/    # RDS PostgreSQL, DynamoDB tables, S3 Buckets
└── 04-compute/        # ECS Clusters, Fargate Task Definitions, ALBs
```

This structure protects state boundaries. Network and database layers change infrequently, while application compute layers deploy continuously.

---

## 3. Drift Detection and Code Hygiene

Infrastructure drift occurs when operators make manual modifications directly inside the cloud console.

To stop drift and maintain code hygiene:
- **Routine Drift Scans:** Run scheduled daily `terraform plan -detailed-exitcode` checks in GitHub Actions. If exit code returns 2, an alert notifies the engineering team of undocumented changes.
- **Strict Variable Typing:** Declare explicit types and validation blocks on all input variables.
- **Standardized Tagging:** Enforce standard resource tags (`Environment`, `ManagedBy = Terraform`, `Project`, `Owner`) for cost allocation and compliance tracking.
