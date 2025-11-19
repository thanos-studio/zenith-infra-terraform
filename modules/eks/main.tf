data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  cluster_name = substr(lower(join("-", compact([var.project_name, var.environment, var.cluster_name]))), 0, 100)

  external_secrets_role = templatefile("${path.module}/policies/external-secrets-role.json", {
    AWS_ACCOUNT_ID   = data.aws_caller_identity.current.account_id
    AWS_REGION       = data.aws_region.current.name
    OIDC_PROVIDER_ID = aws_iam_openid_connect_provider.cluster.url
  })

  external_secrets_policy = templatefile("${path.module}/policies/external-secrets-policy.json", {
    AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    AWS_REGION     = data.aws_region.current.name
  })

  tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Sigmoid"
    },
    var.tags,
    {
      Name = local.cluster_name
    }
  )
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.cluster_log_retention_days
  tags              = local.tags
}

### --------------------------------------------------
### Security Groups
### --------------------------------------------------
resource "aws_security_group" "cluster" {
  name        = "${local.cluster_name}-cluster-sg"
  description = "Security group for the EKS control plane"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${local.cluster_name}-cluster-sg" })
}

resource "aws_security_group" "node" {
  name        = "${local.cluster_name}-node-sg"
  description = "Security group for EKS managed node groups"
  vpc_id      = var.vpc_id

  tags = merge(local.tags, { Name = "${local.cluster_name}-node-sg" })
}

resource "aws_security_group_rule" "cluster_ingress_nodes" {
  type                     = "ingress"
  security_group_id        = aws_security_group.cluster.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  description              = "Allow API traffic from worker nodes"
}

resource "aws_security_group_rule" "cluster_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.cluster.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow cluster control plane egress"
}

resource "aws_security_group_rule" "node_ingress_cluster_api" {
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  description              = "Allow API server callbacks from cluster security group"
}

resource "aws_security_group_rule" "node_ingress_self" {
  type                     = "ingress"
  security_group_id        = aws_security_group.node.id
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node.id
  description              = "Allow node-to-node communication"
}

resource "aws_security_group_rule" "node_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.node.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow worker node egress"
}

### --------------------------------------------------
### EKS Cluster
### --------------------------------------------------
resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [aws_cloudwatch_log_group.cluster]

  tags = local.tags
}

data "tls_certificate" "cluster_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = local.tags
}

data "aws_iam_policy_document" "cloudwatch_observability_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
    }

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:amazon-cloudwatch:*"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}


### --------------------------------------------------
### Node Group
### --------------------------------------------------
resource "aws_launch_template" "node" {
  name_prefix            = "${local.cluster_name}-ng-"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.node.id]
  tags                   = merge(local.tags, { Name = "${local.cluster_name}-ng" })

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.node_disk_size
      volume_type = "gp3"
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name                                          = "${local.cluster_name}-node"
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    })
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${local.cluster_name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types
  ami_type       = var.node_ami_type

  labels = var.node_labels

  launch_template {
    id      = aws_launch_template.node.id
    version = aws_launch_template.node.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [aws_eks_cluster.this]

  tags = local.tags
}

### --------------------------------------------------
### Add-ons
### --------------------------------------------------
resource "aws_iam_role" "cloudwatch_observability" {
  count = var.enable_container_insights ? 1 : 0

  name               = "${local.cluster_name}-cloudwatch-observability"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_observability_assume_role.json

  tags = merge(local.tags, { Name = "${local.cluster_name}-cloudwatch-observability" })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability_cloudwatch" {
  count = var.enable_container_insights ? 1 : 0

  role       = aws_iam_role.cloudwatch_observability[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_observability_xray" {
  count = var.enable_container_insights ? 1 : 0

  role       = aws_iam_role.cloudwatch_observability[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

resource "aws_eks_addon" "cloudwatch_observability" {
  count                       = var.enable_container_insights ? 1 : 0
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "amazon-cloudwatch-observability"
  service_account_role_arn    = aws_iam_role.cloudwatch_observability[count.index].arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    agent = {
      config = {
        logs = {
          metrics_collected = {
            kubernetes = {
              enhanced_container_insights = true
            }
          }
        }
      }
    }
  })

  depends_on = [
    aws_eks_cluster.this,
    aws_eks_node_group.this,
    aws_iam_openid_connect_provider.cluster,
    aws_iam_role_policy_attachment.cloudwatch_observability_cloudwatch,
    aws_iam_role_policy_attachment.cloudwatch_observability_xray
  ]
}

### --------------------------------------------------
### IAM Role for External Secrets Operator
### --------------------------------------------------
resource "aws_iam_role" "external_secrets_operator_role" {
  name               = "${local.cluster_name}-external-secrets-operator-role"
  assume_role_policy = local.external_secrets_role
}

resource "aws_iam_policy" "external_secrets_operator_policy" {
  name   = "${local.cluster_name}-external-secrets-operator-policy"
  policy = local.external_secrets_policy

  tags = merge(local.tags, { Name = "${local.cluster_name}-external-secrets-operator-policy" })
}

resource "aws_iam_role_policy_attachment" "external_secrets_operator_policy_attachment" {
  role       = aws_iam_role.external_secrets_operator_role.name
  policy_arn = aws_iam_policy.external_secrets_operator_policy.arn
}
