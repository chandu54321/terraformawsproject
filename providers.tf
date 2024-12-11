terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.76.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-backned"
    key            = "demo/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "firstterraform"
  }

}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}