variable "prefix" {
  description = "The prefix for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "bastion_instance_type" {
  description = "The instance type for the bastion host"
  type        = string
  default     = "t3.micro"
}

variable "bastion_key_name" {
  description = "The name of the bastion key"
  type        = string
}

variable "bastion_instance_profile_name" {
  description = "The name of the bastion instance profile"
  type        = string
}