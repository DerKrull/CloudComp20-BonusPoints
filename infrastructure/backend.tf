terraform {
  backend "s3" {
    bucket = "cloudcomp20-terraform-state-bucket"
    region = "us-east-1"
    key    = "cloudcomp20.tfstate"
  }
}