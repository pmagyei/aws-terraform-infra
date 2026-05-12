# AWS Zero-Trust Telemetry Infrastructure

Automated, least-privilege AWS infrastructure deployed via GitHub Actions and Terraform. This project focuses on eliminating hardcoded credentials, closing all inbound network ports, and establishing deep system observability.

## Architecture Highlights

* **Keyless CI/CD:** Uses OpenID Connect (OIDC) to authenticate GitHub Actions to AWS, eliminating static IAM Access Keys.
* **Zero-Trust Access:** No SSH keys. No Port 22. Secure shell access is managed entirely through AWS Systems Manager (SSM) Session Manager.
* **Automated Observability:** EC2 instances are bootstrapped via `cloud-init` to install and configure Amazon CloudWatch Agent, pushing custom memory and disk metrics to CloudWatch.
* **Remote State:** Terraform state management using an S3 backend with S3 native locking to prevent concurrent pipeline execution corruption.
* **Least Privilege:** IAM Roles generated via AWS IAM Access Analyzer based on actual CloudTrail API telemetry.

## 📂 Repository Structure

```text
.
├── .github/
│   └── workflows/                # CI/CD pipeline with OIDC authentication
│       └── terraform-plan.yaml
|       |__ terraform-apply.yaml
|       |__ terraform-destroy.yaml     
├── terraform/
│   ├── provider.tf         # AWS provider and S3/DynamoDB backend configuration
│   ├── iam.tf              # OIDC, EC2 Instance Profiles, and Policies
│   ├── ec2.tf              # EC2 instance, Security Groups, and user_data bootstrap
│   └── variables.tf        # Environment variables and AMI definitions
