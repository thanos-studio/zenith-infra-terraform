locals {
  cluster_name = substr(lower(join("-", compact([var.project_name, var.environment, var.cluster_name]))), 0, 100)

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

### --------------------------------------------------
### Node Group
### --------------------------------------------------
resource "aws_launch_template" "node" {
  name_prefix            = "${local.cluster_name}-ng-"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.node.id]
  tags                   = merge(local.tags, { Name = "${local.cluster_name}-ng" })

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
  disk_size      = var.node_disk_size
  ami_type       = "AL2_x86_64"

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
resource "aws_eks_addon" "cloudwatch_observability" {
  count                       = var.enable_container_insights ? 1 : 0
  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
