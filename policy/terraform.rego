package terraform

# Only evaluate resource changes that are not no-op
resource_changes[rc] {
  some i
  rc := input.resource_changes[i]

  some j
  action := rc.change.actions[j]
  action != "no-op"
}

################################################################################
# Deny: block SSH open to the world
################################################################################
deny[msg] {
  rc := resource_changes[_]
  rc.type == "aws_security_group_rule"
  after := rc.change.after

  after.type == "ingress"
  after.protocol == "tcp"
  after.from_port <= 22
  after.to_port >= 22

  some k
  cidr := after.cidr_blocks[k]
  cidr == "0.0.0.0/0"

  msg := sprintf("%s: SSH (22/tcp) open to 0.0.0.0/0 is not allowed", [rc.address])
}

################################################################################
# Warn: alarms should set treat_missing_data explicitly
################################################################################
warn[msg] {
  rc := resource_changes[_]
  rc.type == "aws_cloudwatch_metric_alarm"
  after := rc.change.after

  not after.treat_missing_data
  msg := sprintf("%s: aws_cloudwatch_metric_alarm should set treat_missing_data explicitly", [rc.address])
}
