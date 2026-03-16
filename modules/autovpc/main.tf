data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_names = slice(
    data.aws_availability_zones.available.names,
    0,
    min(2, length(data.aws_availability_zones.available.names))
  )

  subnet_pow2_to_bits = {
    1 = 0
    2 = 1
    4 = 2
  }
}

locals {
  vpcs = {
    for name, cfg in var.free_vpc_config : name => {
      name          = name
      cidr_block    = "${cfg.vpc_base}/${cfg.vpc_mask}"
      vpc_mask      = cfg.vpc_mask
      subnet_count  = cfg.subnet_count
      az_count      = cfg.az_count
      nat_requested = false
      nat_effective = false

      subnet_bits = lookup(local.subnet_pow2_to_bits, cfg.subnet_count, 99)
      subnet_mask = cfg.vpc_mask + lookup(local.subnet_pow2_to_bits, cfg.subnet_count, 99)

      az_count_valid_region = cfg.az_count <= length(local.az_names)

      subnets_per_az = cfg.az_count > 0 ? (cfg.subnet_count / cfg.az_count) : 0
    }
  }

  # Only build subnet plan when the region has enough supported AZs,
  # so Terraform doesn't hit an AZ index error before the precondition fires.
  vpc_subnets = flatten([
    for vpc_name, vpc in local.vpcs : [
      for subnet_index in range(vpc.subnet_count) : {
        vpc_name = vpc_name
        index    = subnet_index

        cidr = cidrsubnet(
          vpc.cidr_block,
          vpc.subnet_bits,
          subnet_index
        )

        az = local.az_names[
          floor(subnet_index / vpc.subnets_per_az)
        ]

        tier = "generic"

        # IGW logic:
        # - if az_count == subnet_count -> every subnet gets IGW default route
        # - else -> only first subnet in each AZ gets IGW default route
        is_igw_subnet = (
          vpc.az_count == vpc.subnet_count ? true : (
            vpc.subnets_per_az > 0 &&
            (subnet_index % vpc.subnets_per_az == 0)
          )
        )
      }
    ]
    if vpc.az_count_valid_region
  ])

  subnet_map = {
    for s in local.vpc_subnets :
    "${s.vpc_name}-${s.index}" => s
  }
}

resource "aws_vpc" "free_vpc" {
  for_each = local.vpcs

  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name      = "${var.prefix}${each.key}"
      ManagedBy = "codreum"
      Tier      = "free"
    },
    var.tags
  )

  lifecycle {
    precondition {
      condition = each.value.az_count_valid_region
      error_message = format(
        "Invalid free VPC '%s': requested az_count (%d) exceeds the number of supported AZs (%d) in region %s.",
        each.key,
        each.value.az_count,
        length(local.az_names),
        var.aws_region,
      )
    }
  }
}

resource "aws_internet_gateway" "free_igw" {
  for_each = aws_vpc.free_vpc

  vpc_id = each.value.id

  tags = merge(
    {
      Name      = "${var.prefix}${each.key}-igw"
      ManagedBy = "codreum"
      Tier      = "free"
    },
    var.tags
  )
}

resource "aws_subnet" "free_sub" {
  for_each = local.subnet_map

  vpc_id            = aws_vpc.free_vpc[each.value.vpc_name].id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    {
      Name      = "${var.prefix}${each.value.vpc_name}-${each.value.index}"
      Tier      = "free"
      ManagedBy = "codreum"
    },
    var.tags
  )
}

resource "aws_route_table" "free_rt" {
  for_each = local.subnet_map

  vpc_id = aws_vpc.free_vpc[each.value.vpc_name].id

  dynamic "route" {
    for_each = each.value.is_igw_subnet ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.free_igw[each.value.vpc_name].id
    }
  }

  tags = merge(
    {
      Name      = "${var.prefix}${each.value.vpc_name}-${each.value.index}-rt"
      Tier      = "free"
      ManagedBy = "codreum"
    },
    var.tags
  )
}

resource "aws_route_table_association" "free_rt_assoc" {
  for_each = aws_route_table.free_rt

  subnet_id      = aws_subnet.free_sub[each.key].id
  route_table_id = each.value.id
}

resource "aws_route53_resolver_query_log_config" "free_vpc" {
  count = var.enable_resolver_query_logging ? 1 : 0

  name            = coalesce(var.resolver_query_log_config_name, "${var.prefix}resolver-query-log")
  destination_arn = var.resolver_query_log_destination_arn

  tags = merge(
    {
      Name      = coalesce(var.resolver_query_log_config_name, "${var.prefix}resolver-query-log")
      ManagedBy = "codreum"
      Tier      = "free"
    },
    var.tags
  )
}

resource "aws_route53_resolver_query_log_config_association" "free_vpc" {
  for_each = var.enable_resolver_query_logging ? aws_vpc.free_vpc : {}

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.free_vpc[0].id
  resource_id                  = each.value.id
}

