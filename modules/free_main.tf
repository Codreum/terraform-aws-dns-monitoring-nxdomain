data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_route53_zone" "free_zone" {
  count  = var.free_zone_id != null ? 1 : 0
  zone_id = var.free_zone_id
}

locals {
  free_zone_name = var.free_zone_id != null ? trimsuffix(data.aws_route53_zone.free_zone[0].name, ".") : null
     product_code = "free"
}

locals {
  has_vpc  = var.free_vpc_id != null
  has_zone = var.free_zone_id != null
}

locals {
  dft_zone_nx_rate_threshold_pct = 10
  dft_vpc_nx_rate_threshold_pct  = 10
  eff_zone_rate_threshold_pct = coalesce(var.free_zone_nxdomain_rate_threshold_pct, local.dft_zone_nx_rate_threshold_pct)
  eff_vpc_rate_threshold_pct  = coalesce(var.free_vpc_nxdomain_rate_threshold_pct,  local.dft_vpc_nx_rate_threshold_pct)
}

locals {
  dft_zone_anom_band_width     = 2.0
  dft_vpc_anom_band_width      = 2.0
  dft_zone_anom_eval_periods   = 3
  dft_vpc_anom_eval_periods    = 3
  eff_zone_anom_band_width     = coalesce(var.free_zone_anomaly_band_width,   local.dft_zone_anom_band_width)
  eff_vpc_anom_band_width      = coalesce(var.free_vpc_anomaly_band_width,    local.dft_vpc_anom_band_width)
  eff_zone_anom_eval_periods   = coalesce(var.free_zone_anomaly_eval_periods, local.dft_zone_anom_eval_periods)
  eff_vpc_anom_eval_periods    = coalesce(var.free_vpc_anomaly_eval_periods,  local.dft_vpc_anom_eval_periods)
}



locals {
  ns             = "Codreum/DNSCI"
  dft_zone_nxdomain_threshold    = 100
  dft_zone_nxdomain_alarm_period = 300
  dft_zone_nxdomain_eval_periods = 1
  dft_zone_topn_nxdomain         = 10
  dft_vpc_nxdomain_threshold     = 200
  dft_vpc_nxdomain_alarm_period  = 300
  dft_vpc_nxdomain_eval_periods  = 1
  dft_vpc_topn_nxdomain          = 10
  eff_zone_threshold     = coalesce(var.free_zone_nxdomain_threshold,     local.dft_zone_nxdomain_threshold)
  eff_zone_period        = coalesce(var.free_zone_nxdomain_alarm_period,  local.dft_zone_nxdomain_alarm_period)
  eff_zone_eval_periods  = coalesce(var.free_zone_nxdomain_eval_periods,  local.dft_zone_nxdomain_eval_periods)
  eff_zone_topn          = coalesce(var.free_zone_topn_nxdomain,          local.dft_zone_topn_nxdomain)
  eff_vpc_threshold      = coalesce(var.free_vpc_nxdomain_threshold,      local.dft_vpc_nxdomain_threshold)
  eff_vpc_period         = coalesce(var.free_vpc_nxdomain_alarm_period,   local.dft_vpc_nxdomain_alarm_period)
  eff_vpc_eval_periods   = coalesce(var.free_vpc_nxdomain_eval_periods,   local.dft_vpc_nxdomain_eval_periods)
  eff_vpc_topn           = coalesce(var.free_vpc_topn_nxdomain,           local.dft_vpc_topn_nxdomain)
}

locals {
  band_warn_ratio    = 0.70  # 70% of threshold → warning
  band_crit_ratio    = 1.00  # 100% of threshold → critical
  zone_warn_value    = local.eff_zone_threshold * local.band_warn_ratio
  zone_crit_value    = local.eff_zone_threshold * local.band_crit_ratio
  vpc_warn_value     = local.eff_vpc_threshold  * local.band_warn_ratio
  vpc_crit_value     = local.eff_vpc_threshold  * local.band_crit_ratio
}

resource "aws_cloudwatch_contributor_insight_rule" "zone_topn_nxdomain_qname" {
  count     = local.has_zone ? 1 : 0
  rule_name  = "${var.prefix}-${local.product_code}-zone-${replace(local.free_zone_name,".","-")}-topn-nxdomain-qname"
  rule_definition = jsonencode({
    Schema        = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [var.free_log_group_name]
    LogFormat     = "CLF"
    Fields = {
      "1"  = "version"
      "2"  = "ts"
      "3"  = "hosted_zone_id"
      "4"  = "qname"
      "5"  = "qtype"
      "6"  = "rcode"
      "7"  = "proto"
      "8"  = "edge"
      "9"  = "rip"
      "10" = "edns"
    }
    Contribution = {
      Keys = ["qname"]
      Filters = [
        { "Match": "rcode",          "In": ["NXDOMAIN"] }, 
        { "Match": "hosted_zone_id", "In": [var.free_zone_id] } 
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_contributor_insight_rule" "zone_topn_nxdomain_qtype" {
  count      = local.has_zone ? 1 : 0
  rule_name  = "${var.prefix}-${local.product_code}-zone-${replace(local.free_zone_name,".","-")}-topn-nxdomain-qtype"
  rule_definition = jsonencode({
    Schema        = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [var.free_log_group_name]
    LogFormat     = "CLF"
    Fields = { "1"="version","2"="ts","3"="hosted_zone_id","4"="qname","5"="qtype","6"="rcode","7"="proto","8"="edge","9"="rip","10"="edns" }
    Contribution  = {
      Keys   = ["qtype"]
      Filters = [
        { Match = "hosted_zone_id", In = [var.free_zone_id] },
        { Match = "rcode",          In = ["NXDOMAIN"] }
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_contributor_insight_rule" "zone_topn_nxdomain_edge" {
  count      = local.has_zone ? 1 : 0
  rule_name  = "${var.prefix}-${local.product_code}-zone-${replace(local.free_zone_name,".","-")}-topn-nxdomain-edge"
  rule_definition = jsonencode({
    Schema        = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [var.free_log_group_name]
    LogFormat     = "CLF"
    Fields = { "1"="version","2"="ts","3"="hosted_zone_id","4"="qname","5"="qtype","6"="rcode","7"="proto","8"="edge","9"="rip","10"="edns" }
    Contribution  = {
      Keys   = ["edge"]
      Filters = [
        { Match = "hosted_zone_id", In = [var.free_zone_id] },
        { Match = "rcode",          In = ["NXDOMAIN"] }
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_contributor_insight_rule" "zone_topn_nxdomain_rip" {
  count      = local.has_zone ? 1 : 0
  rule_name  = "${var.prefix}-${local.product_code}-zone-${replace(local.free_zone_name, ".", "-")}-topn-nxdomain-src"
  rule_definition = jsonencode({
    Schema        = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [var.free_log_group_name]
    LogFormat     = "CLF"
    Fields = {
      "1"  = "version"
      "2"  = "ts"
      "3"  = "hosted_zone_id"
      "4"  = "qname"
      "5"  = "qtype"
      "6"  = "rcode"
      "7"  = "proto"
      "8"  = "edge"
      "9"  = "rip"
      "10" = "edns"
    }
    Contribution = {
      Keys    = ["rip"]
      Filters = [
        { Match = "hosted_zone_id", In = [var.free_zone_id] },
        { Match = "rcode",          In = ["NXDOMAIN"] }
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_log_metric_filter" "zone_nxdomain_count" {
  count          = local.has_zone ? 1 : 0
  name           = "${var.prefix}-${local.product_code}-zone-nxdomain-count"
  log_group_name = var.free_log_group_name
  pattern = "[version, ts, hosted_zone_id=\"${var.free_zone_id}\", qname, qtype, rcode=\"NXDOMAIN\", proto, edge, rip, edns]"
  metric_transformation {
    namespace     = local.ns
    name          = "ZoneNXDOMAIN"
    value         = "1"
    dimensions    = { ZoneId = "$hosted_zone_id"  }
  }
}

resource "aws_cloudwatch_log_metric_filter" "zone_total_count" {
  count          = local.has_zone ? 1 : 0
  name           = "${var.prefix}-${local.product_code}-zone-total-count"
  log_group_name = var.free_log_group_name
  pattern        = "[version, ts, hosted_zone_id=\"${var.free_zone_id}\", qname, qtype, rcode, proto, edge, rip, edns]"
  metric_transformation {
    namespace  = local.ns
    name       = "ZoneTotal"
    value      = "1"
    dimensions = { ZoneId = "$hosted_zone_id" }  # selector required
  }
}

resource "aws_cloudwatch_metric_alarm" "zone_nxdomain_alarm" {
  count                = local.has_zone ? 1 : 0
  alarm_name           = "${var.prefix}-${local.product_code}-zone-${local.free_zone_name}-nxdomain-alarm"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  threshold            = local.eff_zone_threshold
  evaluation_periods   = local.eff_zone_eval_periods
  treat_missing_data   = "notBreaching"
  metric_query {
    id          = "m1"
    return_data = true
    metric {
      namespace   = local.ns
      metric_name = aws_cloudwatch_log_metric_filter.zone_nxdomain_count[0].metric_transformation[0].name  # "ZoneNXDOMAIN"
      dimensions  = { ZoneId = var.free_zone_id } 
      stat        = "Sum"
      period      = local.eff_zone_period
    }
  }
  alarm_actions  = [var.dns_alert_sns_arn]
  ok_actions     = [var.dns_alert_sns_arn]
  alarm_description = "NXDOMAIN count for zone ${local.free_zone_name} exceeded threshold."
  depends_on = [aws_cloudwatch_log_metric_filter.zone_nxdomain_count]
  tags = merge({ "codreum:type" = local.product_code, "codreum:prefix" = var.prefix, "codreum:subject" = "zone:${var.free_zone_id}" }, var.tags)
}

resource "aws_cloudwatch_metric_alarm" "zone_nxdomain_rate_alarm" {
  count               = local.has_zone ? 1 : 0
  alarm_name          = "${var.prefix}-${local.product_code}-zone-${local.free_zone_name}-nxdomain-rate-pct-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = local.eff_zone_rate_threshold_pct
  evaluation_periods  = local.eff_zone_eval_periods
  treat_missing_data  = "notBreaching"
  alarm_description   = "NXDOMAIN rate (%) for zone ${local.free_zone_name} exceeded ${local.eff_zone_rate_threshold_pct}%."
  metric_query {
  id          = "m_nx"
  return_data = false
  metric {
    namespace   = local.ns
    metric_name = "ZoneNXDOMAIN"
    dimensions  = { ZoneId = var.free_zone_id }
    stat        = "Sum"
    period      = local.eff_zone_period
  }
}

metric_query {
  id          = "m_total"
  return_data = false
  metric {
    namespace   = local.ns
    metric_name = "ZoneTotal"
    dimensions  = { ZoneId = var.free_zone_id }
    stat        = "Sum"
    period      = local.eff_zone_period
  }
}

metric_query {
  id          = "e_pct"
  label       = "NXDOMAIN %"
  expression  = "IF(m_total > 0, 100 * m_nx / m_total, 0)"
  return_data = true
}

  alarm_actions = [var.dns_alert_sns_arn]
  ok_actions    = [var.dns_alert_sns_arn]

  depends_on = [
    aws_cloudwatch_log_metric_filter.zone_nxdomain_count,
    aws_cloudwatch_log_metric_filter.zone_total_count
  ]

  tags = merge({
    "codreum:type"    = local.product_code,
    "codreum:prefix"  = var.prefix,
    "codreum:subject" = "zone:${var.free_zone_id}"
  }, var.tags)
}

resource "aws_cloudwatch_metric_alarm" "zone_nxdomain_anomaly" {
  count               = local.has_zone ? 1 : 0
  alarm_name          = "${var.prefix}-${local.product_code}-zone-${local.free_zone_name}-nxdomain-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = local.eff_zone_anom_eval_periods
  treat_missing_data  = "notBreaching"
  alarm_description   = "Anomaly detection on Zone NXDOMAIN count."
  alarm_actions       = [var.dns_alert_sns_arn]
  ok_actions          = [var.dns_alert_sns_arn]
  metric_query {
    id          = "m1"
    return_data = true
    metric {
      namespace   = local.ns
      metric_name = "ZoneNXDOMAIN"
      dimensions  = { ZoneId = var.free_zone_id }
      stat        = "Sum"
      period      = local.eff_zone_period
    }
  }
  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${tostring(local.eff_zone_anom_band_width)})"
    label       = "ZoneNXDOMAIN expected band"
    return_data = true
  }

  threshold_metric_id = "ad1"
}


resource "aws_cloudwatch_metric_alarm" "zone_nxdomain_rate_anomaly" {
  count               = local.has_zone ? 1 : 0
  alarm_name          = "${var.prefix}-${local.product_code}-zone-${local.free_zone_name}-nxdomain-rate-pct-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = local.eff_zone_anom_eval_periods
  treat_missing_data  = "notBreaching"
  alarm_description   = "Anomaly detection on Zone NXDOMAIN rate (%)."
  alarm_actions       = [var.dns_alert_sns_arn]
  ok_actions          = [var.dns_alert_sns_arn]

  metric_query {
    id          = "m_nx"
    return_data = false
    metric {
      namespace   = local.ns
      metric_name = "ZoneNXDOMAIN"
      dimensions  = { ZoneId = var.free_zone_id }
      stat        = "Sum"
      period      = local.eff_zone_period
    }
  }
  metric_query {
    id          = "m_total"
    return_data = false
    metric {
      namespace   = local.ns
      metric_name = "ZoneTotal"
      dimensions  = { ZoneId = var.free_zone_id }
      stat        = "Sum"
      period      = local.eff_zone_period
    }
  }
  metric_query {
    id          = "e_pct"
    expression  = "IF(m_total > 0, 100 * m_nx / m_total, 0)"
    label       = "NXDOMAIN %"
    return_data = true
  }
  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(e_pct, ${tostring(local.eff_zone_anom_band_width)})"
    label       = "NXDOMAIN % expected band"
    return_data = true
  }

  threshold_metric_id = "ad1"
}

resource "aws_cloudwatch_contributor_insight_rule" "vpc_topn_nxdomain_qname" {
  count     = local.has_vpc ? 1 : 0
  rule_name  = "${var.prefix}-${local.product_code}-vpc-${var.free_vpc_id}-topn-nxdomain-qname"

  rule_definition = jsonencode({
    Schema = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [var.free_log_group_name]
    LogFormat = "JSON"
    Contribution = {
      Keys    = ["$.qname"]
      Filters = [
        { "Match": "$.rcode", "In": ["NXDOMAIN"] },
        { "Match": "$.vpc_id", "In": [var.free_vpc_id] }
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_contributor_insight_rule" "vpc_topn_nxdomain_srcip" {
  count      = local.has_vpc ? 1 : 0
  rule_name  = "${var.prefix}-${local.product_code}-vpc-${var.free_vpc_id}-topn-nxdomain-src"
  rule_definition = jsonencode({
    Schema        = { Name = "CloudWatchLogRule", Version = 1 }
    LogGroupNames = [var.free_log_group_name]
    LogFormat     = "JSON"
    Contribution  = {
      Keys   = ["$.srcaddr"]
      Filters = [
        { Match = "$.vpc_id", In = [var.free_vpc_id] },
        { Match = "$.rcode",  In = ["NXDOMAIN"] }  
      ]
    }
    AggregateOn = "Count"
  })
}

resource "aws_cloudwatch_log_metric_filter" "vpc_nxdomain_count" { 
   count = local.has_vpc ? 1 : 0 
   name = "${var.prefix}-${local.product_code}-vpc-nxdomain-count" 
   log_group_name = var.free_log_group_name  
  pattern = "{ ($.rcode = \"NXDOMAIN\") && ($.vpc_id = \"${var.free_vpc_id}\") }"
  metric_transformation {
    namespace  = local.ns
    name       = "VpcNXDOMAIN"
    value      = "1"
    dimensions = { VpcId = "$.vpc_id" }
  }
   depends_on = [aws_cloudwatch_contributor_insight_rule.vpc_topn_nxdomain_qname]
 } 

resource "aws_cloudwatch_log_metric_filter" "vpc_total_count" { 
   count = local.has_vpc ? 1 : 0 
   name = "${var.prefix}-${local.product_code}-vpc-total-count"
   log_group_name = var.free_log_group_name
  pattern = "{ $.vpc_id = \"${var.free_vpc_id}\" }"
  metric_transformation {
    namespace  = local.ns
    name       = "VpcTotal"
    value      = "1"
    dimensions = { VpcId = "$.vpc_id" }
  }
}

resource "aws_cloudwatch_metric_alarm" "vpc_nxdomain_alarm" {
  count                = local.has_vpc ? 1 : 0
  alarm_name           = "${var.prefix}-${local.product_code}-vpc-${var.free_vpc_id}-nxdomain-alarm"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  threshold            = local.eff_vpc_threshold
  evaluation_periods   = local.eff_vpc_eval_periods
  treat_missing_data   = "notBreaching"

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      namespace   = local.ns
      metric_name = aws_cloudwatch_log_metric_filter.vpc_nxdomain_count[0].metric_transformation[0].name  # "VpcNXDOMAIN"
      dimensions  = { VpcId = var.free_vpc_id }
      stat        = "Sum"
      period      = local.eff_vpc_period 
    }
  }

  alarm_actions  = [var.dns_alert_sns_arn]
  ok_actions     = [var.dns_alert_sns_arn]
  alarm_description = "NXDOMAIN count for VPC ${var.free_vpc_id} exceeded threshold."

  depends_on = [aws_cloudwatch_log_metric_filter.vpc_nxdomain_count]
  tags = merge({ "codreum:type" = local.product_code, "codreum:prefix" = var.prefix, "codreum:subject" = "vpc:${var.free_vpc_id}" }, var.tags)
}


resource "aws_cloudwatch_metric_alarm" "vpc_nxdomain_rate_alarm" {
  count               = local.has_vpc ? 1 : 0
  alarm_name          = "${var.prefix}-${local.product_code}-vpc-${var.free_vpc_id}-nxdomain-rate-pct-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = local.eff_vpc_rate_threshold_pct
  evaluation_periods  = local.eff_vpc_eval_periods
  treat_missing_data  = "notBreaching"
  alarm_description   = "NXDOMAIN rate (%) for VPC ${var.free_vpc_id} exceeded ${local.eff_vpc_rate_threshold_pct}%."

 metric_query {
  id          = "m_nx"
  return_data = false
  metric {
    namespace   = local.ns
    metric_name = "VpcNXDOMAIN"
    dimensions  = { VpcId = var.free_vpc_id }
    stat        = "Sum"
    period      = local.eff_vpc_period
  }
}

metric_query {
  id          = "m_total"
  return_data = false
  metric {
    namespace   = local.ns
    metric_name = "VpcTotal"
    dimensions  = { VpcId = var.free_vpc_id }
    stat        = "Sum"
    period      = local.eff_vpc_period
  }
}

metric_query {
  id          = "e_pct"
  label       = "NXDOMAIN %"
  expression  = "IF(m_total > 0, 100 * m_nx / m_total, 0)"
  return_data = true
}

  alarm_actions = [var.dns_alert_sns_arn]
  ok_actions    = [var.dns_alert_sns_arn]

  depends_on = [
    aws_cloudwatch_log_metric_filter.vpc_nxdomain_count,
    aws_cloudwatch_log_metric_filter.vpc_total_count
  ]

  tags = merge({
    "codreum:type"    = local.product_code,
    "codreum:prefix"  = var.prefix,
    "codreum:subject" = "vpc:${var.free_vpc_id}"
  }, var.tags)
}

resource "aws_cloudwatch_metric_alarm" "vpc_nxdomain_anomaly" {
  count               = local.has_vpc ? 1 : 0
  alarm_name          = "${var.prefix}-${local.product_code}-vpc-${var.free_vpc_id}-nxdomain-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = local.eff_vpc_anom_eval_periods
  treat_missing_data  = "notBreaching"
  alarm_description   = "Anomaly detection on VPC NXDOMAIN count."
  alarm_actions       = [var.dns_alert_sns_arn]
  ok_actions          = [var.dns_alert_sns_arn]

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      namespace   = local.ns
      metric_name = "VpcNXDOMAIN"
      dimensions  = { VpcId = var.free_vpc_id }
      stat        = "Sum"
      period      = local.eff_vpc_period
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${tostring(local.eff_vpc_anom_band_width)})"
    label       = "VpcNXDOMAIN expected band"
    return_data = true
  }

  threshold_metric_id = "ad1"
}

resource "aws_cloudwatch_metric_alarm" "vpc_nxdomain_rate_anomaly" {
  count               = local.has_vpc ? 1 : 0
  alarm_name          = "${var.prefix}-${local.product_code}-vpc-${var.free_vpc_id}-nxdomain-rate-pct-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = local.eff_vpc_anom_eval_periods
  treat_missing_data  = "notBreaching"
  alarm_description   = "Anomaly detection on VPC NXDOMAIN rate (%)."
  alarm_actions       = [var.dns_alert_sns_arn]
  ok_actions          = [var.dns_alert_sns_arn]
  metric_query {
    id          = "m_nx"
    return_data = false
    metric {
      namespace   = local.ns
      metric_name = "VpcNXDOMAIN"
      dimensions  = { VpcId = var.free_vpc_id }
      stat        = "Sum"
      period      = local.eff_vpc_period
    }
  }
  metric_query {
    id          = "m_total"
    return_data = false
    metric {
      namespace   = local.ns
      metric_name = "VpcTotal"
      dimensions  = { VpcId = var.free_vpc_id }
      stat        = "Sum"
      period      = local.eff_vpc_period
    }
  }

  metric_query {
    id          = "e_pct"
    expression  = "IF(m_total > 0, 100 * m_nx / m_total, 0)"
    label       = "NXDOMAIN %"
    return_data = true
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(e_pct, ${tostring(local.eff_vpc_anom_band_width)})"
    label       = "NXDOMAIN % expected band"
    return_data = true
  }

  threshold_metric_id = "ad1"
}

resource "aws_cloudwatch_dashboard" "zone_dns_dashboard" {
  count          = local.has_zone ? 1 : 0
  dashboard_name = "${var.prefix}-${local.product_code}-zone-${replace(local.free_zone_name, ".", "-")}"

  dashboard_body = jsonencode({
    start          = "-PT3H"
    periodOverride = "inherit"
    widgets = [
      {
        "type": "text",
        "x": 0, "y": 0, "width": 24, "height": 2,
        "properties": {
          "markdown": "## 🌐 Zone NXDOMAIN — **${local.free_zone_name}**  \n**Namespace:** `${local.ns}`  •  **ZoneId:** `${var.free_zone_id}`"
        }
      },

      {
        "type": "metric",
        "x": 0, "y": 2, "width": 6, "height": 5,
        "properties": {
          "title": "NXDOMAIN (Sum)",
          "view": "singleValue",
          "sparkline": true,
          "region": "${var.aws_region}",
          "setPeriodToTimeRange": true,
          "stat": "Sum",
          "metrics": [
            [ local.ns, "ZoneNXDOMAIN", "ZoneId", var.free_zone_id ]
          ]
        }
      },

  {
  "type": "metric",
  "x": 6, "y": 2, "width": 6, "height": 5,
  "properties": {
    "title": "NXDOMAIN / min",
    "view": "singleValue",
    "sparkline": true,
    "region": "${var.aws_region}",
    "setPeriodToTimeRange": false,
    "period": local.eff_zone_period,   // e.g., 300
    "metrics": [
      [ { "expression": "m1/5", "label": "NXDOMAIN / min", "id": "e1" } ],
      [ local.ns, "ZoneNXDOMAIN", "ZoneId", var.free_zone_id, { "id": "m1", "stat": "Sum", "visible": false } ]
    ]
  }
}
,

      {
        "type": "metric",
        "x": 12, "y": 2, "width": 12, "height": 5,
        "properties": {
          "title": "NXDOMAIN — Gauge vs Threshold",
          "view": "gauge",
          "region": "${var.aws_region}",
          "stat": "Sum",
          "period": local.eff_zone_period,
          "setPeriodToTimeRange": false,
          "metrics": [
            [ local.ns, "ZoneNXDOMAIN", "ZoneId", var.free_zone_id, { "label": "NXDOMAIN (period sum)" } ]
          ],
          "yAxis": { "left": { "min": 0, "max": local.eff_zone_threshold * 1.5 } },
          "annotations": {
            "horizontal": [
              { "label": "Warning ≥ ${tostring(local.zone_warn_value)}",   "value": local.zone_warn_value,  "color": "#f2b705" },
              { "label": "Critical ≥ ${tostring(local.zone_crit_value)}", "value": local.zone_crit_value, "color": "#d13212" }
            ]
          }
        }
      },

      {
        "type": "alarm",
        "x": 0,  "y": 7, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — Zone NXDOMAIN (static)",
          "alarms": [ aws_cloudwatch_metric_alarm.zone_nxdomain_alarm[0].arn ]
        }
      },

      {
        "type": "alarm",
        "x": 6,  "y": 7, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — Zone NXDOMAIN Anomaly",
          "alarms": [ aws_cloudwatch_metric_alarm.zone_nxdomain_anomaly[0].arn ]
        }
      },

{
  "type": "log",
  "x": 12, "y": 7, "width": 12, "height": 5,
  "properties": {
    "title": "NXDOMAIN QTYPE distribution",
    "region": "${var.aws_region}",
    "view": "pie",
    "query": join(" ", [
      format("SOURCE '%s'", var.free_log_group_name),
      "| parse @message /(?<version>\\S+)\\s+(?<ts>\\S+)\\s+(?<hosted_zone_id>\\S+)\\s+(?<qname>\\S+)\\s+(?<qtype>\\S+)\\s+(?<rcode>\\S+)\\s+(?<proto>\\S+)\\s+(?<edge>\\S+)\\s+(?<rip>\\S+)\\s+(?<edns>\\S+)/",
      format("| filter hosted_zone_id = '%s' and rcode = 'NXDOMAIN'", var.free_zone_id),
      "| stats count(*) as count by qtype",
      "| sort count desc",
      format("| limit %d", local.eff_zone_topn)
    ])
  }
},

      {
        "type": "alarm",
        "x": 0,  "y": 12, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — Zone NXDOMAIN Rate (%)",
          "alarms": [ aws_cloudwatch_metric_alarm.zone_nxdomain_rate_alarm[0].arn ]
        }
      },

      {
        "type": "alarm",
        "x": 6,  "y": 12, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — Zone NXDOMAIN Rate (%) Anomaly",
          "alarms": [ aws_cloudwatch_metric_alarm.zone_nxdomain_rate_anomaly[0].arn ]
        }
      },

 {
  "type": "log",
  "x": 12, "y": 12, "width": 12, "height": 8,
  "properties": {
    "title": "Top ${local.eff_zone_topn} NXDOMAIN by QTYPE",
    "region": "${var.aws_region}",
    "view": "table",
    "query": join(" ", [
      format("SOURCE '%s'", var.free_log_group_name),
      "| parse @message /(?<version>\\S+)\\s+(?<ts>\\S+)\\s+(?<hosted_zone_id>\\S+)\\s+(?<qname>\\S+)\\s+(?<qtype>\\S+)\\s+(?<rcode>\\S+)\\s+(?<proto>\\S+)\\s+(?<edge>\\S+)\\s+(?<rip>\\S+)\\s+(?<edns>\\S+)/",
      format("| filter hosted_zone_id = '%s' and rcode = 'NXDOMAIN'", var.free_zone_id),
      "| stats count(*) as count by qtype",
      "| sort count desc",
      format("| limit %d", local.eff_zone_topn)
    ])
  }
},

{
  "type": "log",
  "x": 0, "y": 20, "width": 12, "height": 8,
  "properties": {
    "title": "Top ${local.eff_zone_topn} NXDOMAIN by Edge",
    "region": "${var.aws_region}",
    "view": "table",
    "query": join(" ", [
      format("SOURCE '%s'", var.free_log_group_name),
      "| parse @message /(?<version>\\S+)\\s+(?<ts>\\S+)\\s+(?<hosted_zone_id>\\S+)\\s+(?<qname>\\S+)\\s+(?<qtype>\\S+)\\s+(?<rcode>\\S+)\\s+(?<proto>\\S+)\\s+(?<edge>\\S+)\\s+(?<rip>\\S+)\\s+(?<edns>\\S+)/",
      format("| filter hosted_zone_id = '%s' and rcode = 'NXDOMAIN'", var.free_zone_id),
      "| stats count(*) as count by edge",
      "| sort count desc",
      format("| limit %d", local.eff_zone_topn)
    ])
  }
},

      # Top FQDN NXDOMAIN — Zone (already existed, kept as-is)
      {
        "type": "log",
        "x": 12, "y": 20, "width": 12, "height": 8,
        "properties": {
          "title": "Top ${local.eff_zone_topn} NXDOMAIN by Domain",
          "region": "${var.aws_region}",
          "view": "table",
          "query": join(" ", [
            format("SOURCE '%s'", var.free_log_group_name),
            "| parse @message /(?<version>\\S+)\\s+(?<ts>\\S+)\\s+(?<hosted_zone_id>\\S+)\\s+(?<qname>\\S+)\\s+(?<qtype>\\S+)\\s+(?<rcode>\\S+)\\s+(?<proto>\\S+)\\s+(?<edge>\\S+)\\s+(?<rip>\\S+)\\s+(?<edns>\\S+)/",
            format("| filter hosted_zone_id = '%s' and rcode = 'NXDOMAIN'", var.free_zone_id),
            "| fields qname as domain_name",
            "| stats count(*) as count by domain_name",
            "| sort count desc",
            format("| limit %d", local.eff_zone_topn)
          ])
        }
      },

      # NEW: Top source NXDOMAIN — Zone
      {
        "type" : "log",
        "x" : 0, "y" : 28, "width" : 12, "height" : 8,
        "properties" : {
          "title"  : "Top NXDOMAIN — source (zone)",
          "view"   : "table",
          "region" : "${var.aws_region}",
          "query"  : format(
            "SOURCE '%s' | %s",
            var.free_log_group_name,
            join("\n| ", [
              "parse @message /(?<version>\\S+)\\s+(?<ts>\\S+)\\s+(?<hosted_zone_id>\\S+)\\s+(?<qname>\\S+)\\s+(?<qtype>\\S+)\\s+(?<rcode>\\S+)\\s+(?<proto>\\S+)\\s+(?<edge>\\S+)\\s+(?<rip>\\S+)\\s+(?<edns>\\S+)/",
              format("filter hosted_zone_id = '%s' and rcode = 'NXDOMAIN'", var.free_zone_id),
              "fields rip as client_ip",
              "stats count(*) as count by client_ip",
              "sort count desc",
              format("limit %d", local.eff_zone_topn)
            ])
          )
        }
      },

{
  "type": "metric",
  "x": 0, "y": 36, "width": 24, "height": 7,
  "properties": {
    "title": "NXDOMAIN Count — Time Series",
    "view": "timeSeries",
    "stat": "Sum",
    "region": "${var.aws_region}",
    "period": local.eff_zone_period,
    "metrics": [
      [
        {
          "expression": "FILL(m1, 0)",
          "label": "ZoneNXDOMAIN (filled)",
          "id": "e1",
          "region": "${var.aws_region}"
        }
      ],
      [
        local.ns, "ZoneNXDOMAIN", "ZoneId", var.free_zone_id,
        { "id": "m1", "stat": "Sum", "visible": false }
      ]
    ],
    "annotations": {
      "horizontal": [
        {
          "label": "Threshold",
          "value": local.eff_zone_threshold
        }
      ]
    }
  }
},

      {
        "type": "metric",
        "x": 0, "y": 43, "width": 24, "height": 7,
        "properties": {
          "title": "NXDOMAIN Count — with Anomaly Band",
          "view": "timeSeries",
          "region": "${var.aws_region}",
          "stat": "Sum",
          "period": local.eff_zone_period,
          "metrics": [
            [
              {
                "expression": "ANOMALY_DETECTION_BAND(m1, ${local.eff_zone_anom_band_width})",
                "label": "Band",
                "id": "ad1",
                "region": "${var.aws_region}"
              }
            ],
            [ local.ns, "ZoneNXDOMAIN", "ZoneId", var.free_zone_id, { "id": "m1" } ]
          ]
        }
      },

      {
        "type": "metric",
        "x": 0, "y": 50, "width": 24, "height": 7,
        "properties": {
          "title": "NXDOMAIN Rate (%) — with Anomaly Band",
          "view": "timeSeries",
          "region": "${var.aws_region}",
          "stat": "Average",
          "period": local.eff_zone_period,
          "metrics": [
            [
              {
                "expression": "IF(m_total > 0, 100 * m_nx / m_total, 0)",
                "label": "%",
                "id": "e_pct_ts",
                "region": "${var.aws_region}"
              }
            ],
            [
              {
                "expression": "ANOMALY_DETECTION_BAND(e_pct_ts, ${local.eff_zone_anom_band_width})",
                "label": "Band",
                "id": "ad_pct",
                "region": "${var.aws_region}"
              }
            ],
            [ local.ns, "ZoneNXDOMAIN", "ZoneId", var.free_zone_id, { "id": "m_nx", "stat": "Sum", "visible": false } ],
            [ local.ns, "ZoneTotal",    "ZoneId", var.free_zone_id, { "id": "m_total", "stat": "Sum", "visible": false } ]
          ]
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "vpc_dns_dashboard" {
  count          = local.has_vpc ? 1 : 0
  dashboard_name = "${var.prefix}-${local.product_code}-vpc-${var.free_vpc_id}"

  dashboard_body = jsonencode({
    start          = "-PT3H"
    periodOverride = "inherit"
    widgets = [
      {
        "type": "text",
        "x": 0, "y": 0, "width": 24, "height": 2,
        "properties": {
          "markdown": "## 🏗️ VPC NXDOMAIN — **${var.free_vpc_id}**  \n**Namespace:** `${local.ns}`"
        }
      },

      {
        "type": "metric",
        "x": 0, "y": 2, "width": 6, "height": 5,
        "properties": {
          "title": "NXDOMAIN (Sum)",
          "view": "singleValue",
          "sparkline": true,
          "region": "${var.aws_region}",
          "setPeriodToTimeRange": true,
          "stat": "Sum",
          "metrics": [
            [ local.ns, "VpcNXDOMAIN", "VpcId", var.free_vpc_id ]
          ]
        }
      },

      {
        "type": "metric",
        "x": 6, "y": 2, "width": 6, "height": 5,
        "properties": {
          "title": "NXDOMAIN / min",
          "view": "singleValue",
          "sparkline": true,
          "region": "${var.aws_region}",
          "setPeriodToTimeRange": false,
          "period": 60,
          "stat": "Sum",
          "metrics": [
            [ local.ns, "VpcNXDOMAIN", "VpcId", var.free_vpc_id ]
          ]
        }
      },

      {
        "type": "metric",
        "x": 12, "y": 2, "width": 12, "height": 5,
        "properties": {
          "title": "NXDOMAIN — Gauge vs Threshold",
          "view": "gauge",
          "region": "${var.aws_region}",
          "stat": "Sum",
          "period": local.eff_vpc_period,
          "setPeriodToTimeRange": false,
          "metrics": [
            [ local.ns, "VpcNXDOMAIN", "VpcId", var.free_vpc_id, { "label": "NXDOMAIN (period sum)" } ]
          ],
          "yAxis": { "left": { "min": 0, "max": local.eff_vpc_threshold * 1.5 } },
          "annotations": {
            "horizontal": [
              { "label": "Warning ≥ ${tostring(local.vpc_warn_value)}",   "value": local.vpc_warn_value,  "color": "#f2b705" },
              { "label": "Critical ≥ ${tostring(local.vpc_crit_value)}", "value": local.vpc_crit_value, "color": "#d13212" }
            ]
          }
        }
      },

      {
        "type": "alarm",
        "x": 0,  "y": 7, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — VPC NXDOMAIN (static)",
          "alarms": [ aws_cloudwatch_metric_alarm.vpc_nxdomain_alarm[0].arn ]
        }
      },

      {
        "type": "alarm",
        "x": 6,  "y": 7, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — VPC NXDOMAIN Anomaly",
          "alarms": [ aws_cloudwatch_metric_alarm.vpc_nxdomain_anomaly[0].arn ]
        }
      },

      {
        "type": "metric",
        "x": 12, "y": 7, "width": 12, "height": 5,
        "properties": {
          "title": "NXDOMAIN Rate (%) — single value",
          "view": "singleValue",
          "region": "${var.aws_region}",
          "setPeriodToTimeRange": false,
          "period": local.eff_vpc_period,
          "stat": "Average",
          "metrics": [
            [
              {
                "expression": "FILL(IF(m_total > 0, 100 * m_nx / m_total, 0), 0)",
                "id": "e_pct",
                "label": "pct",
                "region": "${var.aws_region}"
              }
            ],
            [ local.ns, "VpcNXDOMAIN", "VpcId", var.free_vpc_id, { "id": "m_nx", "stat": "Sum", "visible": false } ],
            [ local.ns, "VpcTotal",    "VpcId", var.free_vpc_id, { "id": "m_total", "stat": "Sum", "visible": false } ]
          ]
        }
      },

      {
        "type": "alarm",
        "x": 0,  "y": 12, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — VPC NXDOMAIN Rate (%)",
          "alarms": [ aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_alarm[0].arn ]
        }
      },

      {
        "type": "alarm",
        "x": 6,  "y": 12, "width": 6, "height": 5,
        "properties": {
          "title": "Alarm — VPC NXDOMAIN Rate (%) Anomaly",
          "alarms": [ aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_anomaly[0].arn ]
        }
      },

      {
        "type": "metric",
        "x": 12, "y": 12, "width": 12, "height": 8,
        "properties": {
          "title": "Top ${local.eff_vpc_topn} NXDOMAIN by Source IP",
          "region": "${var.aws_region}",
          "view": "timeSeries",
          "stat": "Sum",
          "period": 300,
          "metrics": [
            [
              {
                "id": "e1",
                "label": "Top-N by SrcIP",
                "region": "${var.aws_region}",
                "expression": format(
                  "INSIGHT_RULE_METRIC(\"%s\", \"Sum\")",
                  aws_cloudwatch_contributor_insight_rule.vpc_topn_nxdomain_srcip[0].rule_name
                )
              }
            ]
          ]
        }
      },

{
  "type": "metric",
  "x": 0, "y": 20, "width": 24, "height": 8,
  "properties": {
    "title": "NXDOMAIN Count — Time Series",
    "view": "timeSeries",
    "stat": "Sum",
    "region": "${var.aws_region}",
    "period": local.eff_vpc_period,
    "metrics": [
      [
        {
          "expression": "FILL(m1, 0)",
          "label": "VpcNXDOMAIN (filled)",
          "id": "e1",
          "region": "${var.aws_region}"
        }
      ],
      [
        local.ns, "VpcNXDOMAIN", "VpcId", var.free_vpc_id,
        { "id": "m1", "stat": "Sum", "visible": false }
      ]
    ],
    "annotations": {
      "horizontal": [
        {
          "label": "Threshold",
          "value": local.eff_vpc_threshold
        }
      ]
    }
  }
},


      {
        "type": "metric",
        "x": 0, "y": 28, "width": 24, "height": 7,
        "properties": {
          "title": "NXDOMAIN Count — with Anomaly Band",
          "view": "timeSeries",
          "region": "${var.aws_region}",
          "stat": "Sum",
          "period": local.eff_vpc_period,
          "metrics": [
            [
              {
                "expression": "ANOMALY_DETECTION_BAND(m1, ${local.eff_vpc_anom_band_width})",
                "label": "Band",
                "id": "ad1",
                "region": "${var.aws_region}"
              }
            ],
            [ local.ns, "VpcNXDOMAIN", "VpcId", var.free_vpc_id, { "id": "m1" } ]
          ]
        }
      },

      {
        "type": "metric",
        "x": 0, "y": 35, "width": 24, "height": 7,
        "properties": {
          "title": "NXDOMAIN Rate (%) — with Anomaly Band",
          "view": "timeSeries",
          "region": "${var.aws_region}",
          "stat": "Average",
          "period": local.eff_vpc_period,
          "metrics": [
            [
              {
                "expression": "IF(m_total > 0, 100 * m_nx / m_total, 0)",
                "label": "%",
                "id": "e_pct_ts",
                "region": "${var.aws_region}"
              }
            ],
            [
              {
                "expression": "ANOMALY_DETECTION_BAND(e_pct_ts, ${local.eff_vpc_anom_band_width})",
                "label": "Band",
                "id": "ad_pct",
                "region": "${var.aws_region}"
              }
            ],
            [ local.ns, "VpcNXDOMAIN", "VpcId", var.free_vpc_id, { "id": "m_nx", "stat": "Sum", "visible": false } ],
            [ local.ns, "VpcTotal",    "VpcId", var.free_vpc_id, { "id": "m_total", "stat": "Sum", "visible": false } ]
          ]
        }
      },

      # NEW: Top source NXDOMAIN — VPC
      {
        "type" : "log",
        "x" : 0, "y" : 42, "width" : 12, "height" : 8,
        "properties" : {
          "title"  : "Top NXDOMAIN — source (vpc)",
          "view"   : "table",
          "region" : "${var.aws_region}",
          "query"  : format(
            "SOURCE '%s' | %s",
            var.free_log_group_name,
            join("\n| ", [
              format("filter vpc_id = '%s' and rcode = 'NXDOMAIN'", var.free_vpc_id),
              "fields srcaddr as client_ip",
              "stats count(*) as count by client_ip",
              "sort count desc",
              format("limit %d", local.eff_vpc_topn)
            ])
          )
        }
      },

      # NEW: Top FQDN NXDOMAIN — VPC
      {
        "type" : "log",
        "x" : 12, "y" : 42, "width" : 12, "height" : 8,
        "properties" : {
          "title"  : "Top NXDOMAIN — domain name (vpc)",
          "view"   : "table",
          "region" : "${var.aws_region}",
          "query"  : format(
            "SOURCE '%s' | %s",
            var.free_log_group_name,
            join("\n| ", [
              format("filter vpc_id = '%s' and rcode = 'NXDOMAIN'", var.free_vpc_id),
              "fields query_name as domain_name",
              "stats count(*) as count by domain_name",
              "sort count desc",
              format("limit %d", local.eff_vpc_topn)
            ])
          )
        }
      }
    ]
  })
}

resource "aws_cloudwatch_dashboard" "ops_dns_landing" {
  dashboard_name = "${var.prefix}-${local.product_code}-dns-ops"

  dashboard_body = jsonencode({
    start          = "-PT24H"
    periodOverride = "inherit"
    widgets = [
      {
        "type": "text",
        "x": 0, "y": 0, "width": 24, "height": 7,
        "properties": {
          "markdown": join("\n", [
            "## 🧭 DNS Ops — Landing",
            "",
            "**Product:** `${local.product_code}`  •  **Prefix:** `${var.prefix}`  •  **Region:** `${var.aws_region}`",
            "",
            local.has_zone ?
            format(
              "- 🌐 **Zone Dashboard:** [%s](https://console.aws.amazon.com/cloudwatch/home?region=%s#dashboards:name=%s)",
              replace(local.free_zone_name, ".", "-"),
              var.aws_region,
              format("%s-%s-zone-%s", var.prefix, local.product_code, replace(local.free_zone_name, ".", "-"))
            )
            :
            "- 🌐 **Zone Dashboard:** _not configured (set `free_zone_id`)_",
            local.has_vpc ?
            format(
              "- 🏗️ **VPC Dashboard:** [%s](https://console.aws.amazon.com/cloudwatch/home?region=%s#dashboards:name=%s)",
              var.free_vpc_id,
              var.aws_region,
              format("%s-%s-vpc-%s", var.prefix, local.product_code, var.free_vpc_id)
            )
            :
            "- 🏗️ **VPC Dashboard:** _not configured (set `free_vpc_id`)_",
            "",
            "---",
            "### Quick Tips",
            "- Alarms fire on NXDOMAIN **count**, **rate (%)**, and **anomalies** for both.",
            "- Zone uses CLF logs (hosted_zone_id/qname), VPC uses JSON logs (vpcId/queryName).",
            "- Use Top-QTYPE/Edge (Zone) and Top-SourceIP (VPC) for triage."
          ])
        }
      }
    ]
  })
}

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
    ops_name  = aws_cloudwatch_dashboard.ops_dns_landing.dashboard_name
    ops_url   = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.ops_dns_landing.dashboard_name}"

    zone_name = local.has_zone ? aws_cloudwatch_dashboard.zone_dns_dashboard[0].dashboard_name : null
    zone_url  = local.has_zone ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.zone_dns_dashboard[0].dashboard_name}" : null

    vpc_name  = local.has_vpc ? aws_cloudwatch_dashboard.vpc_dns_dashboard[0].dashboard_name : null
    vpc_url   = local.has_vpc ? "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.vpc_dns_dashboard[0].dashboard_name}" : null
  }
}

# -----------------------
# Alarms (names + ARNs)
# -----------------------
output "alarms" {
  description = "Alarm names and ARNs for integrating with other systems."
  value = {
    zone = local.has_zone ? {
      nxdomain_static_name      = aws_cloudwatch_metric_alarm.zone_nxdomain_alarm[0].alarm_name
      nxdomain_static_arn       = aws_cloudwatch_metric_alarm.zone_nxdomain_alarm[0].arn

      nxdomain_rate_name        = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_alarm[0].alarm_name
      nxdomain_rate_arn         = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_alarm[0].arn

      nxdomain_anomaly_name     = aws_cloudwatch_metric_alarm.zone_nxdomain_anomaly[0].alarm_name
      nxdomain_anomaly_arn      = aws_cloudwatch_metric_alarm.zone_nxdomain_anomaly[0].arn

      nxdomain_rate_anom_name   = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_anomaly[0].alarm_name
      nxdomain_rate_anom_arn    = aws_cloudwatch_metric_alarm.zone_nxdomain_rate_anomaly[0].arn
    } : null

    vpc = local.has_vpc ? {
      nxdomain_static_name      = aws_cloudwatch_metric_alarm.vpc_nxdomain_alarm[0].alarm_name
      nxdomain_static_arn       = aws_cloudwatch_metric_alarm.vpc_nxdomain_alarm[0].arn

      nxdomain_rate_name        = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_alarm[0].alarm_name
      nxdomain_rate_arn         = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_alarm[0].arn

      nxdomain_anomaly_name     = aws_cloudwatch_metric_alarm.vpc_nxdomain_anomaly[0].alarm_name
      nxdomain_anomaly_arn      = aws_cloudwatch_metric_alarm.vpc_nxdomain_anomaly[0].arn

      nxdomain_rate_anom_name   = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_anomaly[0].alarm_name
      nxdomain_rate_anom_arn    = aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_anomaly[0].arn
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
      dimension_value = var.free_zone_id
    } : null

    vpc = local.has_vpc ? {
      nxdomain_metric = "VpcNXDOMAIN"
      total_metric    = "VpcTotal"
      dimension_key   = "VpcId"
      dimension_value = var.free_vpc_id
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
