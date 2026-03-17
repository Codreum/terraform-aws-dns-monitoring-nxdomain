output "autovpc_vpc_ids" {
  value = module.codreum_autovpc.vpc_ids
}

output "autovpc_subnet_plan" {
  value = module.codreum_autovpc.subnet_plan
}

output "dns_NX_enabled" {
  value = module.codreum_dns_NX.enabled
}

output "dns_NX_dashboards" {
  value = module.codreum_dns_NX.dashboards
}

output "dns_NX_alarms" {
  value = module.codreum_dns_NX.alarms
}

output "dns_NX_metrics" {
  value = module.codreum_dns_NX.metrics
}

output "dns_NX_ci_rules" {
  value = module.codreum_dns_NX.contributor_insights_rules
}