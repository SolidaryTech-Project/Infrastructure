terraform {
  backend "s3" {
    bucket = "terraform-state-solidary-tech-backend"
    key    = "Togglemaster/Development/terraform.tfstate"
    region = "us-east-1"
  }
}
