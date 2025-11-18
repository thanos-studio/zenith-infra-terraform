output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block associated with the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets spread across the availability zones."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets spread across the availability zones."
  value       = aws_subnet.private[*].id
}

output "protected_subnet_ids" {
  description = "IDs of the protected subnets spread across the availability zones."
  value       = aws_subnet.protected[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table that connects to the internet gateway."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables that route traffic through the NAT gateway."
  value       = aws_route_table.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway attached to the VPC."
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT gateways created per availability zone."
  value       = aws_nat_gateway.main[*].id
}

output "nat_eip_ids" {
  description = "Allocation IDs of the Elastic IPs attached to the NAT gateways."
  value       = aws_eip.nat_eip[*].id
}

output "bastion_security_group_id" {
  description = "ID of the security group attached to the bastion host."
  value       = aws_security_group.bastion.id
}

output "bastion_instance_id" {
  description = "ID of the Amazon Linux 2023 bastion EC2 instance."
  value       = aws_instance.bastion.id
}

output "bastion_instance_public_ip" {
  description = "Public IP address assigned to the bastion host."
  value       = aws_instance.bastion.public_ip
}

output "bastion_instance_private_ip" {
  description = "Private IP address assigned to the bastion host."
  value       = aws_instance.bastion.private_ip
}

output "bastion_eip_allocation_id" {
  description = "Allocation ID of the Elastic IP reserved for the bastion host."
  value       = aws_eip.bastion_eip.id
}
