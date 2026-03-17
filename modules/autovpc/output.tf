output "vpc_ids" {
  value = { for k, v in aws_vpc.free_vpc : k => v.id }
}

output "subnet_plan" {
  value = {
    for key, s in local.subnet_map :
    key => {
      vpc_name      = s.vpc_name
      subnet_index  = s.index
      cidr_block    = s.cidr
      az            = s.az
      is_igw_subnet = s.is_igw_subnet
      vpc_id        = aws_vpc.free_vpc[s.vpc_name].id
      subnet_id     = aws_subnet.free_sub[key].id
    }
  }
}

output "resolver_query_log_config_id" {
  value = try(aws_route53_resolver_query_log_config.free_vpc[0].id, null)
}

output "resolver_query_log_config_arn" {
  value = try(aws_route53_resolver_query_log_config.free_vpc[0].arn, null)
}