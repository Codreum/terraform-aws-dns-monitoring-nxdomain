package terraform

# Only evaluate resources that are being created/updated/deleted (not no-op)
resource_changes[rc] {
  rc := input.resource_changes[_]
  some a
  a := rc.change.actions[_]
  a != "no-op"
}

################################################################################
# Example "deny" (hard fail): block SSH open to the world (if SG rules exist)
################################################################################
deny[msg] {
  rc := resource_changes[_]
  rc.type == "aws_security_group_rule"
  after := rc.change.after

  after.type == "ingress"
  after.from_port <= 22
  after.to_port >= 22
  after.protocol == "tcp"

  some cidr
  cidr := after.cidr_blocks[_]
  cidr == "0.0.0.0/0"

  msg := sprintf("%s: SSH (22/tcp) open to 0.0.0.0/0 is not allowed", [rc.address])
}

################################################################################
# Example "warn" (soft): alarms should set treat_missing_data explicitly
################################################################################
warn[msg] {
  rc := resource_changes[_]
  rc.type == "aws_cloudwatch_metric_alarm"
  after := rc.change.after

  not after.treat_missing_data
  msg := sprintf("%s: aws_cloudwatch_metric_alarm should set treat_missing_data explicitly", [rc.address])
}
