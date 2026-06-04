terraform {
  backend "s3" {
    bucket = "terraform-state-solidary-tech-backend"
    key    = "Togglemaster/Staging/terraform.tfstate"
    region = "us-east-1"
  }
}
