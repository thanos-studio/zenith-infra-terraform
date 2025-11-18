data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  prefix = "${var.project_name}-${var.environment}"

  assume_role_policy_path = "${path.module}/policies/assumerole_policy.json"
}

# Create the bastion role
resource "aws_iam_role" "bastion_role" {
  name = "${local.prefix}-bastion-role"
  assume_role_policy = templatefile(local.assume_role_policy_path, {
    SERVICE_URL = "ec2.amazonaws.com"
  })
  tags = {
    Name = "${local.prefix}-bastion-role"
  }
}

# Attach the PowerUserAccess policy to the bastion role (for general access to AWS resources)
resource "aws_iam_role_policy_attachment" "bastion_poweruser_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# Attach the AmazonSSMManagedInstanceCore policy to the bastion role (for SSM access to ec2 instances)
resource "aws_iam_role_policy_attachment" "bastion_ssm_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create the bastion instance profile (ec2 attachable)
resource "aws_iam_instance_profile" "bastion_profile" {
  name = "${local.prefix}-bastion-profile"
  role = aws_iam_role.bastion_role.name
}

# EKS cluster role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${local.prefix}-eks-cluster-role"
  assume_role_policy = templatefile(local.assume_role_policy_path, {
    SERVICE_URL = "eks.amazonaws.com"
  })

  tags = {
    Name = "${local.prefix}-eks-cluster-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_vpc_controller_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# EKS node role
resource "aws_iam_role" "eks_node_role" {
  name = "${local.prefix}-eks-node-role"
  assume_role_policy = templatefile(local.assume_role_policy_path, {
    SERVICE_URL = "ec2.amazonaws.com"
  })

  tags = {
    Name = "${local.prefix}-eks-node-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cloudwatch_agent_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
