# Examples — terraform-aws-dns-monitoring-nxdomain

This directory contains **ready-to-run Terraform examples** for the **(NXDOMAIN)** DNS monitoring module.  
Each example is a complete Terraform configuration that calls the module and outputs key artifacts (dashboards, alarms, metrics, enabled scopes).

---

## Examples

| Example | What it enables | Folder |
|--------|------------------|--------|
| **Both Zone + VPC** | Route53 Hosted Zone NXDOMAIN + VPC/Resolver NXDOMAIN monitoring | `examples/both-zone-vpc` |
| **Zone only** | Route53 Hosted Zone NXDOMAIN monitoring | `examples/zone-only` |
| **VPC only** | VPC/Resolver NXDOMAIN monitoring | `examples/vpc-only` |

Each folder includes:
- `main.tf` — module invocation
- `outputs.tf` — dashboards, alarms, metrics, and enabled scopes

> Tip: Start with **both-zone-vpc** first — it demonstrates the full feature set.

---

## Prerequisites

### 1) Terraform
Recommended: **Terraform `>= 1.14.0`**  
(If an example folder declares a higher `required_version`, follow that requirement.)

### 2) AWS credentials
Configure AWS credentials using one of:
- `AWS_PROFILE` + `~/.aws/credentials`
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (optional `AWS_SESSION_TOKEN`)
- Any other supported AWS auth mechanism (SSO, IAM role, etc.)

### 3) Existing CloudWatch log group with DNS logs
You must have an existing CloudWatch Logs log group that is **already receiving DNS query logs** in the expected format.

#### Zone (Route53 Hosted Zone) — CLF-style logs
Expected fields include:
- `hosted_zone_id`, `qname`, `qtype`, `rcode`, `edge`, `rip`

#### VPC / Resolver — JSON-style logs
Expected fields include:
- `vpc_id`, `srcaddr`, `query_name`, `rcode`

> If your logs use different field names or a different log format, dashboards and metric filters may display **No data**.

### 4) Existing SNS topic ARN for alerts
You must provide:
- `dns_alert_sns_arn` — SNS topic ARN that receives alarm notifications.

### 5) IAM permissions
Your AWS identity must be able to create/read:
- CloudWatch Dashboards, Alarms, Log Metric Filters, Contributor Insights Rules  
- (and read the target log group / publish to SNS as applicable in your account)

---

## Module source (important)

This repository exposes the Terraform module from the **`modules/`** subdirectory.  
Replace the existing module source "../../modules" with "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules?ref=v0.1.0"

```hcl
module "codreum_dns_NX" {
  source = "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules?ref=v0.1.0"
}
```

---

## Required inputs

All examples require:

- `prefix` — name prefix for created resources
- `aws_region` — AWS region for dashboards/alarms
- `tags` — resource tags
- `NX_log_group_name` — CloudWatch Logs log group that contains the DNS logs
- `dns_alert_sns_arn` — SNS topic ARN for alarm notifications

Enable scope(s) by setting one or both of the following:
- `NX_zone_id` — enables **Zone** resources
- `NX_vpc_id` — enables **VPC** resources

> **Important:** Set `NX_log_group_name` to the **actual CloudWatch log group name** that is already receiving DNS logs for the Hosted Zone (`NX_zone_id`) and/or VPC (`NX_vpc_id`) you want to monitor.

---

## Quick start

### 1) Choose an example folder
```bash
cd examples/both-zone-vpc
# or:
# cd examples/zone-only
# cd examples/vpc-only
```

### 2) Update values in `main.tf`
At minimum, update:
- `aws_region`
- `NX_log_group_name`
- `dns_alert_sns_arn`
- `NX_zone_id` and/or `NX_vpc_id` (depending on the example)

### Optional: override module defaults (quick tuning)

Each example `main.tf` includes a commented “tuning” section listing the most common override variables.  
If you **uncomment and set** any of these, Terraform will use your values. If you leave them commented, the module will use its **built-in defaults**.

In zone-only, only Zone variables apply. In vpc-only, only VPC variables apply.

Add / keep this block in each example `main.tf` (edit values as needed):

```hcl
  # ----------------------------
  # Optional tuning (overrides)
  # ----------------------------

  # Zone (Hosted Zone) tuning
  # NX_zone_nxdomain_threshold         = 
  # NX_zone_nxdomain_alarm_period      = 
  # NX_zone_nxdomain_eval_periods      = 
  # NX_zone_topn_nxdomain              = 
  # NX_zone_nxdomain_rate_threshold_pct = 
  # NX_zone_anomaly_band_width         = 
  # NX_zone_anomaly_eval_periods       = 

  # VPC (Resolver) tuning
  # NX_vpc_nxdomain_threshold          = 
  # NX_vpc_nxdomain_alarm_period       = 
  # NX_vpc_nxdomain_eval_periods       = 
  # NX_vpc_topn_nxdomain               = 
  # NX_vpc_nxdomain_rate_threshold_pct = 
  # NX_vpc_anomaly_band_width          = 
  # NX_vpc_anomaly_eval_periods        = 
```

Default values (if you don’t override):
- Zone
  - NX_zone_nxdomain_threshold = 100
  - NX_zone_nxdomain_alarm_period = 300
  - NX_zone_nxdomain_eval_periods = 1
  - NX_zone_topn_nxdomain = 10
  - NX_zone_nxdomain_rate_threshold_pct = 10
  - NX_zone_anomaly_band_width = 2.0
  - NX_zone_anomaly_eval_periods = 3

- VPC
  - NX_vpc_nxdomain_threshold = 200
  - NX_vpc_nxdomain_alarm_period = 300
  - NX_vpc_nxdomain_eval_periods = 1
  - NX_vpc_topn_nxdomain = 10
  - NX_vpc_nxdomain_rate_threshold_pct = 10
  - NX_vpc_anomaly_band_width = 2.0
  - NX_vpc_anomaly_eval_periods = 3


### 3) Initialize and deploy
```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### 4) View outputs
```bash
terraform output
```

### 5) Cleanup
```bash
terraform destroy
```

---

## What this deploys

Depending on enabled scopes, the module creates:

### 1) Dashboards
- **Ops Landing** dashboard (summary + links + triage guidance)
- **Zone NXDOMAIN** dashboard (when `NX_zone_id` is set)
- **VPC NXDOMAIN** dashboard (when `NX_vpc_id` is set)

### 2) Alarms (per enabled scope)
- NXDOMAIN **count** (static threshold)
- NXDOMAIN **rate (%)** (static threshold)
- NXDOMAIN **count anomaly**
- NXDOMAIN **rate (%) anomaly**

### 3) Metrics (from CloudWatch log metric filters)
- Zone:
  - `ZoneNXDOMAIN`
  - `ZoneTotal`
- VPC:
  - `VpcNXDOMAIN`
  - `VpcTotal`

### 4) Contributor Insights rules (Top-N offenders)
- Zone examples typically include Top-N by:
  - domain (`qname`), query type (`qtype`), edge, source IP (`rip`)
- VPC examples typically include Top-N by:
  - domain (`query_name`/qname), source IP (`srcaddr`)

---

## Folder conventions

- `both-zone-vpc`  
  Sets **both** `NX_zone_id` and `NX_vpc_id` (enables both scopes).

- `zone-only`  
  Sets **only** `NX_zone_id` (omit `NX_vpc_id`).

- `vpc-only`  
  Sets **only** `NX_vpc_id` (omit `NX_zone_id`).

---

## Troubleshooting

### 1) Dashboards show “No data”
Common causes:
- Incorrect `NX_log_group_name` or wrong AWS region
- Logs are not arriving recently
- Log format does not match expectations (CLF vs JSON / field names differ)
- Metric filters have not matched any events yet

### 2) Alarms are stuck in “Insufficient data”
- Wait for metrics to accumulate (especially in low-traffic environments)
- Confirm the log group contains NXDOMAIN events for the selected scope
- Temporarily lower thresholds to validate wiring in a test environment

### 3) Terraform cannot download the module source
- Ensure the source uses `//modules`:
  - `github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules?ref=v0.1.0`
- Ensure the tag exists and matches exactly (e.g., `v0.1.0`)

Re-run:
```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

---

## Notes
- These examples are designed to be copied and adapted into your own repositories.
- For production, ensure SNS subscriptions, IAM permissions, and alert routing follow your organization’s standards.
