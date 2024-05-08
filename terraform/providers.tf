provider "aws" {
}

provider "github" {
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
    github = {
      source = "integrations/github"
      version = "6.2.1"
    }
  }
  backend "s3" {
    bucket = "blog-markfrancis-io-tfstate"
    key    = "blog"
    region = "eu-west-2"  # london
  }
  required_version = " 1.7.5"
}
