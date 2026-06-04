terraform {
  backend "s3" {
    bucket = "terraform-state-solidary-tech-backend"
    key    = "Togglemaster/Production/terraform.tfstate"
    region = "us-east-1"
  }
}
