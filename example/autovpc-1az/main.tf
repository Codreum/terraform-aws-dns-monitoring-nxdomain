terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.2.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

module "codreum_autovpc" {
  source = "../../modules/autovpc"

  prefix     = "poc-1-"
  aws_region = "ap-southeast-1"
  tags       = { env = "poc", owner = "user-name" }

  free_vpc_config = {
    main = {
      vpc_base     = "10.10.0.0"
      vpc_mask     = 24
      subnet_count = 1
      az_count     = 1
    }
  }
}