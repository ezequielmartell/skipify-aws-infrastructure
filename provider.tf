provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "thinkmartell-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}
