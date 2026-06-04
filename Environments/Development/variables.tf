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
