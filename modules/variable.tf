variable "prefix"        {
   type = string
 }

variable "aws_region"    { 
   type = string 
}


variable "tags"          { 
   type = map(string) 
}

variable "free_log_group_name" {
  description = "CloudWatch Logs group for Route 53 Resolver query logs."
  type        = string
}

variable "free_vpc_id" {
  description = "Optional VPC to scope NXDOMAIN client insights & alarm."
  type        = string
  default     = null
}

variable "free_zone_id" {
  description = "Optional hosted zone (Zxxxxxxxx) to scope 'top NXDOMAIN names'."
  type        = string
  default     = null
}

variable "dns_alert_sns_arn" {
  description = "SNS ARN for alarms."
  type        = string
}

variable "free_zone_nxdomain_threshold"        {
 type = number 
default = null 
} # count per period

variable "free_zone_nxdomain_alarm_period" { 
type = number
 default = null 
} # seconds, e.g., 300

variable "free_zone_nxdomain_eval_periods"     { 
type = number 
default = null 
} # e.g., 1

variable "free_zone_topn_nxdomain"             { 
type = number 
default = null
 } # e.g., 10

# VPC: alarm & dashboard knobs

variable "free_vpc_nxdomain_threshold"         { 
type = number 
default = null
 }

variable "free_vpc_nxdomain_alarm_period"      { 
type = number 
default = null
 }

variable "free_vpc_nxdomain_eval_periods"      { 
type = number 
default = null 
}

variable "free_vpc_topn_nxdomain"              { 
type = number 
default = null 
}

variable "free_zone_nxdomain_rate_threshold_pct" { 
  type = number
  default = null 
} # e.g., 10 (%)

variable "free_vpc_nxdomain_rate_threshold_pct"  {
 type = number
 default = null 
} # e.g., 10 (%)

## anomaly var##
# --- Anomaly knobs (optional overrides) ---
variable "free_zone_anomaly_band_width" {
  description = "Std-dev width for anomaly band on Zone metrics (e.g., 2.0 ≈ ~95%)."
  type        = number
  default     = null
}

variable "free_vpc_anomaly_band_width" {
  description = "Std-dev width for anomaly band on VPC metrics."
  type        = number
  default     = null
}

variable "free_zone_anomaly_eval_periods" {
  description = "Evaluation periods for Zone anomaly alarms."
  type        = number
  default     = null
}

variable "free_vpc_anomaly_eval_periods" {
  description = "Evaluation periods for VPC anomaly alarms."
  type        = number
  default     = null
}
