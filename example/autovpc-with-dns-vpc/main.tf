terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.4.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "codreum_autovpc" {
  source = "../../modules/autovpc"

  prefix     = "poc-1-"
  aws_region = "us-east-1"
  tags       = { env = "poc", owner = "user-name" }

  free_vpc_config = {
    main = {
      vpc_base     = "10.40.0.0"
      vpc_mask     = 24
      subnet_count = 2
      az_count     = 2
    }
  }

  enable_resolver_query_logging      = true
  resolver_query_log_destination_arn = "arn:aws:logs:us-east-1:123456789123:log-group:/aws/route53/resolver-query-logs"
}

module "codreum_dns_NX" {
  source = "../../modules/nxdomain"

  prefix     = "poc-1"
  aws_region = "us-east-1"
  tags       = { env = "poc", owner = "user-name" }

  # This must point to an existing CloudWatch Logs group that already receives
  # Route 53 Resolver query logs for the VPC created above.
  NX_log_group_name = "/aws/route53/resolver-query-logs"

  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789123:test-topic"
  NX_enable_vpc     = true
  NX_vpc_id         = module.codreum_autovpc.vpc_ids["main"]

  # Optional if you also want to monitor a hosted zone in the same deployment:
  # NX_zone_id = "Z123EXAMPLE"

  # NX_vpc_nxdomain_threshold           =
  # NX_vpc_nxdomain_alarm_period        =
  # NX_vpc_nxdomain_eval_periods        =
  # NX_vpc_topn_nxdomain                =
  # NX_vpc_nxdomain_rate_threshold_pct  =
  # NX_vpc_anomaly_band_width           =
  # NX_vpc_anomaly_eval_periods         =
}