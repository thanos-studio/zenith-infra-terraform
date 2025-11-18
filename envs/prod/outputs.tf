output "rds_instance_identifier" {
  description = "Identifier for the provisioned MySQL instance."
  value       = module.rds.instance_identifier
}

output "rds_endpoint" {
  description = "Address clients should use to reach the MySQL database."
  value       = module.rds.endpoint
}

output "rds_port" {
  description = "Port exposed by the database instance."
  value       = module.rds.port
}

output "rds_security_group_id" {
  description = "Security group protecting the database."
  value       = module.rds.security_group_id
}

output "elasticache_replication_group_id" {
  description = "Identifier of the Redis replication group."
  value       = module.elasticache.replication_group_id
}

output "elasticache_primary_endpoint" {
  description = "Primary endpoint for Redis write operations."
  value       = module.elasticache.primary_endpoint
}

output "elasticache_reader_endpoint" {
  description = "Reader endpoint for Redis replicas."
  value       = module.elasticache.reader_endpoint
}

output "elasticache_port" {
  description = "Port exposed by the Redis cluster."
  value       = module.elasticache.port
}

output "elasticache_security_group_id" {
  description = "Security group attached to the Redis cluster."
  value       = module.elasticache.security_group_id
}

output "ecr_repository_names" {
  description = "Full names of the provisioned ECR repositories keyed by short name."
  value       = module.ecr.repository_names
}

output "ecr_repository_arns" {
  description = "ARNs of the provisioned ECR repositories keyed by short name."
  value       = module.ecr.repository_arns
}

output "ecr_repository_urls" {
  description = "Repository URLs for pushing container images keyed by short name."
  value       = module.ecr.repository_urls
}

output "eks_cluster_name" {
  description = "Provisioned EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API server endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "Security group protecting the EKS control plane."
  value       = module.eks.cluster_security_group_id
}

output "eks_node_security_group_id" {
  description = "Security group attached to worker nodes."
  value       = module.eks.node_security_group_id
}

output "eks_node_group_name" {
  description = "Managed node group name."
  value       = module.eks.node_group_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = module.load_balancers.load_balancer_arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB."
  value       = module.load_balancers.load_balancer_dns_name
}

output "alb_security_group_id" {
  description = "Security group associated with the ALB."
  value       = module.load_balancers.security_group_id
}

output "alb_target_group_arns" {
  description = "Map of target group names to their ARNs for TargetGroupBinding definitions."
  value       = module.load_balancers.target_group_arns
}
