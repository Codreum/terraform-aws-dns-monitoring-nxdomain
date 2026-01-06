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


module "dnsci" {
  source = "../../modules"

  prefix     = "poc-1"
  aws_region = "us-east-1"
  tags       = { env = "poc", owner = "user-name" }

  free_log_group_name = "/aws/route53/free.codreum.com"
  dns_alert_sns_arn   = "arn:aws:sns:us-east-1:123456789123:test-topic"
  free_zone_id        = "ZZ2190931ZUOOWM6BKTYU"

  # free_zone_nxdomain_threshold = 
  # free_zone_nxdomain_alarm_period =
  # free_zone_nxdomain_eval_periods =
  # free_zone_topn_nxdomain =
  # free_zone_nxdomain_rate_threshold_pct =
  # free_zone_anomaly_band_width =
  # free_zone_anomaly_eval_periods =
}

