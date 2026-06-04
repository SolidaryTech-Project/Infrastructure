module "network" {
  source = "git::https://github.com/SolidaryTech-Project/Terraform-Modules.git//Modules/Network?ref=v1.0.0"

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

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
