variable "aws_region" {
  type        = string
  description = "Region for free VPC deployment"
}

variable "prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "free_vpc_config" {
  description = "Free VPC configuration map (supports max 1 VPC)"
  type = map(object({
    vpc_base     = string
    vpc_mask     = number
    subnet_count = number
    az_count     = number
  }))

  validation {
    condition     = length(var.free_vpc_config) <= 1
    error_message = "Free edition supports a maximum of 1 VPC. Provide at most one entry in free_vpc_config."
  }

  validation {
    condition = alltrue([
      for _, cfg in var.free_vpc_config :
      contains([1, 2, 4], cfg.subnet_count)
    ])
    error_message = "subnet_count must be one of 1, 2, or 4."
  }

  validation {
    condition = alltrue([
      for _, cfg in var.free_vpc_config :
      contains([1, 2], cfg.az_count)
    ])
    error_message = "az_count must be one of 1 or 2."
  }

  validation {
    condition = alltrue([
      for _, cfg in var.free_vpc_config :
      contains([1, 2], cfg.az_count)
      ? (cfg.subnet_count >= cfg.az_count && cfg.subnet_count % cfg.az_count == 0)
      : true
    ])
    error_message = "subnet_count must be greater than or equal to az_count, and subnet_count must be divisible by az_count."
  }

  validation {
    condition = alltrue([
      for _, cfg in var.free_vpc_config :
      cfg.vpc_mask >= 16 && cfg.vpc_mask <= 28
    ])
    error_message = "vpc_mask must be between /16 and /28."
  }

  validation {
    condition = alltrue([
      for _, cfg in var.free_vpc_config :
      contains([1, 2, 4], cfg.subnet_count)
      ? (cfg.vpc_mask + lookup({ 1 = 0, 2 = 1, 4 = 2 }, cfg.subnet_count, 99) <= 28)
      : true
    ])
    error_message = "The vpc_mask and subnet_count combination must not produce subnet masks larger than /28."
  }
}

variable "enable_resolver_query_logging" {
  description = "Enable Route 53 Resolver query logging for the created VPC."
  type        = bool
  default     = false
}

variable "resolver_query_log_destination_arn" {
  description = "Destination ARN for Route 53 Resolver query logs. Usually a CloudWatch Logs log group ARN."
  type        = string
  default     = null

  validation {
    condition = (
      var.enable_resolver_query_logging == false ?
      true :
      (
        var.resolver_query_log_destination_arn != null &&
        trimspace(var.resolver_query_log_destination_arn) != ""
      )
    )
    error_message = "resolver_query_log_destination_arn must be set when enable_resolver_query_logging is true."
  }
}

variable "resolver_query_log_config_name" {
  description = "Optional name for the Route 53 Resolver query log config."
  type        = string
  default     = null
}
