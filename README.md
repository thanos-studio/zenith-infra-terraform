# Zenith Infrastructure Terraform

Infrastructure-as-code for the Zenith production stack. The configuration creates a full AWS landing zone—network, compute, storage, secrets, observability, and delivery—using composable Terraform modules so that prod can be bootstrapped from a single `terraform apply`.

---

## Diagram
![ZENITH_INFRA](ZENITH_INFRA.drawio.png)

---

## Architecture Highlights
- **Zero-trust network** – Three-tier VPC, managed bastion host, private/protected subnets, and security groups tuned for RDS, Redis, EKS, and ALBs.
- **Application runtime** – Amazon EKS cluster with managed node groups, per-team node labels, and configurable access/cluster logging.
- **Persistence** – Multi-AZ MySQL RDS instance and Redis (ElastiCache) replication group, each shielded by Secrets Manager credentials.
- **Edge & delivery** – S3 bucket for static assets, dual Application Load Balancers (`app` + `news`), and CloudFront distribution optionally fronting S3/ALB origins.
- **Image supply chain** – Opinionated ECR repositories for workload images.
- **Observability & operations** – CloudWatch dashboards/alarms wired to ALBs, CloudFront, EKS, RDS, and Redis plus IAM roles, key pairs, and automation-friendly tagging.

---

## Repository Layout
```
.
├── envs/
│   └── prod/                 # Standalone Terraform project for production
│       ├── backend.tf        # Remote state (S3 bucket zenith-tfstate)
│       ├── main.tf           # Root module wiring every submodule
│       ├── variable.tf       # Inputs exposed to operators
│       ├── outputs.tf        # Contract exported after apply
│       ├── provider.tf       # aws/tls providers (~> Terraform 1.11)
│       ├── terraform.tfvars  # Real values (ignored from VCS)
│       └── terraform.tfvars.example
├── keypairs/                 # `zenith-kp.pub` consumed by the bastion module
├── modules/                  # Versioned local modules shared by envs
├── hello.tf                  # Sandbox null_resource example (safe to remove)
└── README.md
```

You can add additional environments (e.g., `envs/stage`) by copying `envs/prod` and updating backend + variable defaults.

---

## Module Overview
| Module | Purpose |
| --- | --- |
| `modules/vpc` | Creates VPC, public/private/protected subnets, NAT gateways, routing tables, and SGs including the bastion SG. |
| `modules/ec2` | Launches the hardened bastion EC2 host with SSM-enabled profile and supplied key pair. |
| `modules/iam` | Provisions IAM roles/policies for bastion, EKS cluster, EKS nodes, and any shared service roles. |
| `modules/s3` | Buckets for static web assets with managed CORS + optional logging. |
| `modules/rds` | MySQL instance with parameter groups, subnet groups, security groups, backups, and maintenance windows. |
| `modules/elasticache` | Redis replication group configured for TLS/auth, snapshots, and VPC-restricted ingress. |
| `modules/secrets` | AWS Secrets Manager entries for MySQL master auth, Redis auth token, and optional GitHub token. |
| `modules/ecr` | Namespaced ECR repositories per workload plus lifecycle policies. |
| `modules/eks` | EKS control plane, managed node group, cluster/node security groups, logging, and Container Insights toggles. |
| `modules/load_balancers` | Parameterized Application Load Balancer with listeners, target groups, SG, and optional WAF. |
| `modules/cloudfront` | Edge distribution chaining the static S3 bucket and ALB origins with fine-grained cache behavior. |
| `modules/cloudwatch` | Centralized dashboards/alarms for ALBs, CloudFront, EKS, RDS, and Redis metrics. |

---

## Prerequisites
1. **Tooling**  
   - Terraform `~> 1.11.0`  
   - AWS CLI (for auth and convenience)
2. **AWS access** – Credentials with permission to manage IAM, EC2, VPC, RDS, ElastiCache, EKS, CloudWatch, CloudFront, S3, Secrets Manager, and ECR in `ap-northeast-2`.
3. **Remote state** – S3 bucket `zenith-tfstate` with DynamoDB locking table (recommended). Update `envs/prod/backend.tf` if you use a different bucket/key.
4. **SSH key** – Generate `keypairs/zenith-kp.pub` before running Terraform:
   ```bash
   mkdir -p keypairs
   ssh-keygen -t ed25519 -f keypairs/zenith-kp -C "ops@zenith"
   # Keep the private key outside the repo; only commit `zenith-kp.pub` when needed.
   ```
5. **Stateful secrets** – Vault/GitHub Actions runners should inject sensitive values into `envs/prod/terraform.tfvars` (never commit them).

---

## Configuration
1. Copy the sample vars:
   ```bash
   cp envs/prod/terraform.tfvars.example envs/prod/terraform.tfvars
   ```
2. Populate the following critical values:
   - `rds_master_password` (not in the example; export as TF_VAR or store via `terraform.tfvars`)
   - `elasticache_auth_token` when Redis auth is required
   - `github_token` if `enable_github_secret = true`
   - All placeholder fields in the example file for engine versions, cluster names, capacities, target group definitions, etc.
3. Optional toggles:
   - `enable_redis_secret` – automatically stores the Redis auth token.
   - `enable_github_secret` – writes a GitHub token secret for CI/CD.
   - `cloudfront_config.enabled` – disable CloudFront if you only need ALBs.
4. CIDR controls:
   - `rds_allowed_cidr_blocks`, `elasticache_allowed_cidr_blocks`, and the ALB configs allow you to add office VPN CIDRs beyond the default VPC ranges.

Tip: keep shared values (project name, prefixes) in a `.auto.tfvars` file if you clone this environment for staging.

---

## Terraform Workflow
All commands run from `envs/prod`.

```bash
cd envs/prod

# 1. Initialize backend/providers
terraform init

# 2. Check syntax and modules
terraform validate

# 3. Preview the run
terraform plan -out prod.plan

# 4. Apply when ready
terraform apply prod.plan

# 5. Tear down (if needed)
terraform destroy
```

> Use workspaces or duplicate `envs/<env>` directories if you need parallel stacks. State isolation is handled per directory.

---

## Secrets Management
- Secrets Manager entries are created for MySQL (`mysql_secret_*` outputs) and optionally Redis/GitHub.
- When rotating credentials, update the secret directly in AWS, then re-run `terraform apply` so dependent resources (e.g., user data, parameters) stay in sync.
- Sensitive inputs can be passed via environment variables (`TF_VAR_rds_master_password`) inside CI systems; avoid writing them to disk.

---

## Key Outputs
After apply, run `terraform output` to retrieve:
- Database identifiers (`rds_endpoint`, `rds_port`, `rds_security_group_id`)
- Redis info (`elasticache_primary_endpoint`, `elasticache_reader_endpoint`, SG IDs)
- ECR repository URLs/ARNs for image pushes
- EKS metadata (cluster name, API endpoint, cluster/node SG IDs, node group name)
- ALB DNS names + SGs + target group ARNs for both `app` and `news`
- Secret ARNs/names for MySQL, Redis, and GitHub tokens

Export these into deployment pipelines or kubeconfig generation scripts as needed.

---

## Troubleshooting & Tips
- **State bucket not found** – Update `envs/prod/backend.tf` to match your S3 bucket or create `zenith-tfstate` before running `terraform init`.
- **Missing key pair** – Ensure `keypairs/zenith-kp.pub` exists; Terraform will fail to create the bastion without it.
- **IAM throttling** – Apply with `-parallelism=5` if AWS account limits are tight.
- **EKS auth** – After apply, run `aws eks update-kubeconfig --name <eks_cluster_name> --region <region>` with IAM permissions granted to your user/role.
- **CloudFront cert** – `cloudfront_config.acm_certificate_arn` must reference a certificate in `us-east-1`; create/import it before enabling HTTPS aliases.

---

## Roadmap Ideas
- Add staging/sandbox environments under `envs/`.
- Wire Terraform Cloud or Atlantis for automated plan/apply with policy checks.
- Extend CloudWatch module with PagerDuty or Slack incident hooks.

Happy shipping!
