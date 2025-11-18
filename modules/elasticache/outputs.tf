output "replication_group_id" {
  description = "Identifier of the ElastiCache replication group."
  value       = aws_elasticache_replication_group.main.id
}

output "primary_endpoint" {
  description = "Primary endpoint address for write operations."
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Reader endpoint address for replicas."
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "port" {
  description = "Port exposed by the replication group."
  value       = aws_elasticache_replication_group.main.port
}

output "security_group_id" {
  description = "Security group protecting the cache."
  value       = aws_security_group.main.id
}

output "subnet_group_name" {
  description = "Subnet group associated with the replication group."
  value       = aws_elasticache_subnet_group.main.name
}
