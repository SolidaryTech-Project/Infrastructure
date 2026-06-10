variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "project_name" {
  type        = string
  description = "Project name used as base for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. development, staging, production)"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "rds_username" {
  type        = string
  description = "Master username for the RDS instance"
  default     = "solidarytech"
}

variable "db_name" {
  type        = string
  description = "Default database name created inside the RDS instance"
  default     = "solidarytech"
}

variable "instance_types" {
  type        = list(string)
  description = "EC2 instance types for the EKS node group"
  default     = ["t3.medium"]
}

variable "desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 4
}
