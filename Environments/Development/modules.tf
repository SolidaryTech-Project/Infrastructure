#============================================
# Network
#============================================
module "network" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/Network?ref=main"

  cidr_block       = var.cidr_block
  name             = "${var.project_name}-${var.environment}"
  eks_cluster_name = "${var.project_name}-${var.environment}-cluster"

  subnets = {
    public_a = {
      type      = "public"
      public_ip = true
      az        = "${var.aws_region}a"
    }
    public_b = {
      type      = "public"
      public_ip = true
      az        = "${var.aws_region}b"
    }
    private_a = {
      type      = "private"
      public_ip = false
      az        = "${var.aws_region}a"
    }
    private_b = {
      type      = "private"
      public_ip = false
      az        = "${var.aws_region}b"
    }
  }

  tags = local.tags
}

#============================================
# EKS Cluster
#============================================
module "eks" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/eks-cluster?ref=main"

  name       = "${var.project_name}-${var.environment}"
  subnet_ids = concat(module.network.public_subnet_ids, module.network.private_subnet_ids)
  tags       = local.tags
}

#============================================
# EKS Node Group
#============================================
module "eks_nodegroup" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/eks-nodegroup?ref=main"

  name               = "${var.project_name}-${var.environment}"
  cluster_name       = module.eks.eks_cluster_name
  private_subnet_ids = { for k, v in module.network.subnet_ids : k => v if strcontains(k, "private") }
  instance_types     = var.instance_types
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size
  tags               = local.tags
}

#============================================
# Databases (RDS PostgreSQL + DynamoDB + ElastiCache)
#============================================
module "databases" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/databases?ref=main"

  name               = "${var.project_name}-${var.environment}"
  vpc_id             = module.network.vpc_id
  vpc_cidr           = module.network.vpc_cidr_block
  private_subnet_ids = module.network.private_subnet_ids
  rds_username       = var.rds_username
  db_name            = var.db_name

  # DynamoDB for volunteer-service
  dynamodb_hash_key = "volunteer_id"
  dynamodb_attributes = [
    { name = "volunteer_id", type = "S" }
  ]

  tags = local.tags
}

#============================================
# SQS Queue — donation-service
#============================================
module "donation_queue" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/queue?ref=main"

  name = "${var.project_name}-${var.environment}-donations"
  tags = local.tags
}

#============================================
# ECR Repositories
#============================================
module "ecr_ngo" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/ecr?ref=main"

  name              = "${var.project_name}-${var.environment}-ngo"
  repository_name   = "ngo-service"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  tags              = local.tags
}

module "ecr_donation" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/ecr?ref=main"

  name              = "${var.project_name}-${var.environment}-donation"
  repository_name   = "donation-service"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  tags              = local.tags
}

module "ecr_volunteer" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/ecr?ref=main"

  name              = "${var.project_name}-${var.environment}-volunteer"
  repository_name   = "volunteer-service"
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  tags              = local.tags
}

#============================================
# Secrets Manager + IRSA para ESO
#============================================
module "secrets_manager" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/secrets_manager?ref=main"

  name               = "${var.project_name}-${var.environment}"
  secret_path_prefix = "${var.project_name}/${var.environment}"
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url

  secrets = {
    shared-db-url = {
      description = "Shared database connection URL"
      value       = module.databases.db_instance_endpoint
      service_tag = "shared-db"
    }
    donation-sqs-url = {
      description = "Donation Service SQS queue URL"
      value       = module.donation_queue.sqs_queue_url
      service_tag = "donation-service"
    }
  }

  tags = local.tags
}

#============================================
# Helm (ESO + NGINX Ingress + Metrics Server)
#============================================
module "helm" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/helm?ref=main"

  aws_region   = var.aws_region
  cluster_name = module.eks.eks_cluster_name
  vpc_id       = module.network.vpc_id
  eso_role_arn = module.secrets_manager.eso_role_arn
  depends_on   = [module.eks_nodegroup]
}

#============================================
# Kubernetes (namespaces + ExternalSecrets)
#============================================
module "kubernetes" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/kubernetes?ref=main"

  project_name = var.project_name
  environment  = var.environment

  namespaces_k8s = toset([
    "ngo-service",
    "donation-service",
    "volunteer-service",
  ])

  external_secrets = {
    ngo-db = {
      namespace     = "ngo-service"
      aws_key       = "shared-db-url"
      target_secret = "shared-db-credentials"
    }
    donation-db = {
      namespace     = "donation-service"
      aws_key       = "shared-db-url"
      target_secret = "shared-db-credentials"
    }
    donation-sqs = {
      namespace     = "donation-service"
      aws_key       = "donation-sqs-url"
      target_secret = "donation-sqs-config"
    }
  }

  depends_on = [module.helm]
}
