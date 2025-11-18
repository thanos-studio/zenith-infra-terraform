output "bastion_role_name" {
  description = "Name of the IAM role assumed by the bastion hosts."
  value       = aws_iam_role.bastion_role.name
}

output "bastion_role_arn" {
  description = "ARN of the IAM role assumed by the bastion hosts."
  value       = aws_iam_role.bastion_role.arn
}

output "bastion_instance_profile_name" {
  description = "Name of the instance profile attached to the bastion hosts."
  value       = aws_iam_instance_profile.bastion_profile.name
}

output "bastion_instance_profile_arn" {
  description = "ARN of the instance profile attached to the bastion hosts."
  value       = aws_iam_instance_profile.bastion_profile.arn
}

output "eks_cluster_role_name" {
  description = "Name of the IAM role assumed by the EKS control plane."
  value       = aws_iam_role.eks_cluster_role.name
}

output "eks_cluster_role_arn" {
  description = "ARN of the IAM role assumed by the EKS control plane."
  value       = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_name" {
  description = "Name of the IAM role assumed by the EKS managed node groups."
  value       = aws_iam_role.eks_node_role.name
}

output "eks_node_role_arn" {
  description = "ARN of the IAM role assumed by the EKS managed node groups."
  value       = aws_iam_role.eks_node_role.arn
}
