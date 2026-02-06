terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.2.0"
    }
    http    = { source = "hashicorp/http", version = ">= 3.4.2" }
    archive = { source = "hashicorp/archive", version = ">= 2.4.0" }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "codreum_dns_NX" {
  source = "../../modules"

  prefix     = "poc-1"
  aws_region = "us-east-1"
  tags       = { env = "poc", owner = "user-name" }

  NX_log_group_name = "/aws/route53/free.codreum.com"
  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789123:test-topic"
  NX_vpc_id         = "vpc-06926d7bfefae789c"

  # NX_vpc_nxdomain_threshold =
  # NX_vpc_nxdomain_alarm_period =
  # NX_vpc_nxdomain_eval_periods =
  # NX_vpc_topn_nxdomain =
  # NX_vpc_nxdomain_rate_threshold_pct =
  # NX_vpc_anomaly_band_width =
  # NX_vpc_anomaly_eval_periods =
}

