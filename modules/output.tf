output "enabled" {
  description = "Which modes are enabled in this deployment."
  value = {
    zone = local.has_zone
    vpc  = local.has_vpc
  }
}

# -----------------------
# Dashboards (names + URLs)
# -----------------------
output "dashboards" {
  description = "CloudWatch dashboard names and console URLs."
  value = {
    ops_name = aws_cloudwatch_dashboard.ops_dns_landing.dashboard_name
    ops_url  = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.ops_dns_landing.dashboard_name}"

    zone_name = local.has_zone ? aws_cloudwatch_dashboard.zone_dns_dashboard[0].dashboard_name : null
    zone_url  = local.has_zone ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.zone_dns_dashboard[0].dashboard_name}" : null

    vpc_name = local.has_vpc ? aws_cloudwatch_dashboard.vpc_dns_dashboard[0].dashboard_name : null
    vpc_url  = local.has_vpc ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.vpc_dns_dashboard[0].dashboard_name}" : null
  }
}

# -----------------------
# Alarms (names + ARNs)
# -----------------------
output "alarms" {
  description = "Alarm names and ARNs for integrating with other systems."
  value = {
    zone = local.has_zone ? {
      nxdomain_static_name = aws_cloudwatch_metric_alarm.zone_nxdomain_alarm[0].alarm_name
      nxdomain_static_arn  = aws_cloudwatch_metric_alarm.zone_nxdomain_alarm[0].arn

      nxdomain_rate_name = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_alarm[0].alarm_name
      nxdomain_rate_arn  = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_alarm[0].arn

      nxdomain_anomaly_name = aws_cloudwatch_metric_alarm.zone_nxdomain_anomaly[0].alarm_name
      nxdomain_anomaly_arn  = aws_cloudwatch_metric_alarm.zone_nxdomain_anomaly[0].arn

      nxdomain_rate_anom_name = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_anomaly[0].alarm_name
      nxdomain_rate_anom_arn  = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_anomaly[0].arn
    } : null

    vpc = local.has_vpc ? {
      nxdomain_static_name = aws_cloudwatch_metric_alarm.vpc_nxdomain_alarm[0].alarm_name
      nxdomain_static_arn  = aws_cloudwatch_metric_alarm.vpc_nxdomain_alarm[0].arn

      nxdomain_rate_name = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_alarm[0].alarm_name
      nxdomain_rate_arn  = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_alarm[0].arn

      nxdomain_anomaly_name = aws_cloudwatch_metric_alarm.vpc_nxdomain_anomaly[0].alarm_name
      nxdomain_anomaly_arn  = aws_cloudwatch_metric_alarm.vpc_nxdomain_anomaly[0].arn

      nxdomain_rate_anom_name = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_anomaly[0].alarm_name
      nxdomain_rate_anom_arn  = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_anomaly[0].arn
    } : null
  }
}

# -----------------------
# Metrics (namespace + names)
# -----------------------
output "metrics" {
  description = "Custom metric namespace and metric names created by this module."
  value = {
    namespace = local.ns

    zone = local.has_zone ? {
      nxdomain_metric = "ZoneNXDOMAIN"
      total_metric    = "ZoneTotal"
      dimension_key   = "ZoneId"
      dimension_value = var.NX_zone_id
    } : null

    vpc = local.has_vpc ? {
      nxdomain_metric = "VpcNXDOMAIN"
      total_metric    = "VpcTotal"
      dimension_key   = "VpcId"
      dimension_value = var.NX_vpc_id
    } : null
  }
}

# -----------------------
# Contributor Insights rule names
# -----------------------
output "contributor_insights_rules" {
  description = "Contributor Insights rule names (Top-N) created by this module."
  value = {
    zone = local.has_zone ? {
      top_qname = aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_qname[0].rule_name
      top_qtype = aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_qtype[0].rule_name
      top_edge  = aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_edge[0].rule_name
      top_src   = aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_rip[0].rule_name
    } : null

    vpc = local.has_vpc ? {
      top_qname = aws_cloudwatch_contributor_insight_rule.vpc_topn_nxdomain_qname[0].rule_name
      top_src   = aws_cloudwatch_contributor_insight_rule.vpc_topn_nxdomain_srcip[0].rule_name
    } : null
  }
}