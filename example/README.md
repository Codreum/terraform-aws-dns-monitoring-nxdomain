# Examples — terraform-aws-observability-core

This directory contains **ready-to-run Terraform examples** for the Codreum
modules in this repository.

Each example is a complete Terraform configuration that calls one or more
modules and outputs the key artifacts created by that example.

---

## Examples

| Example | What it enables | Folder |
| --- | --- | --- |
| **Both Zone + VPC** | Route 53 Hosted Zone NXDOMAIN + VPC/Resolver NXDOMAIN monitoring | `example/both-zone-vpc` |
| **Zone only** | Route 53 Hosted Zone NXDOMAIN monitoring | `example/zone-only` |
| **VPC only** | VPC/Resolver NXDOMAIN monitoring | `example/vpc-only` |
| **AutoVPC 1 AZ** | Free AutoVPC deployment with 1 subnet in 1 AZ | `example/autovpc-1az` |
| **AutoVPC 2 AZ** | Free AutoVPC deployment with 2 subnets across 2 AZs | `example/autovpc-2az` |
| **AutoVPC 4 subnets / 2 AZ** | Free AutoVPC deployment with 4 subnets across 2 AZs | `example/autovpc-4subnets-2az` |
| **AutoVPC + DNS VPC** | Creates a free AutoVPC VPC and enables NXDOMAIN VPC monitoring against that VPC | `example/autovpc-with-dns-vpc` |

Each folder includes:

- `main.tf` — module invocation
- `output.tf` — key outputs from that example

> Tip: Start with **both-zone-vpc** for the full NXDOMAIN feature set, or
> **autovpc-with-dns-vpc** if you want to see both modules used in one root
> configuration.

---

## Prerequisites

### 1) Terraform

Recommended: **Terraform `>= 1.12.0`**

If an example folder declares a higher `required_version`, follow that
requirement.

### 2) AWS credentials

Configure AWS credentials using one of:

- `AWS_PROFILE` + `~/.aws/credentials`
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (optional `AWS_SESSION_TOKEN`)
- Any other supported AWS auth mechanism (SSO, IAM role, and so on)

### 3) Existing CloudWatch log group with DNS logs

For NXDOMAIN examples, you must have an existing CloudWatch Logs log group that
is already receiving DNS query logs in the expected format.

#### Zone (Route 53 Hosted Zone) — CLF-style logs

Expected fields include:

- `hosted_zone_id`, `qname`, `qtype`, `rcode`, `edge`, `rip`

#### VPC / Resolver — JSON-style logs

Expected fields include:

- `vpc_id`, `srcaddr`, `query_name`, `rcode`

> If your logs use different field names or a different log format, dashboards
> and metric filters may display **No data**.

### 4) Existing SNS topic ARN for alerts

You must provide:

- `dns_alert_sns_arn` — SNS topic ARN that receives alarm notifications

### 5) Existing CloudWatch Logs log group ARN (AutoVPC optional logging)

If you enable Resolver query logging in AutoVPC, you must provide an existing
CloudWatch Logs log group ARN.

> The AutoVPC free module does **not** create the CloudWatch Logs log group for
> DNS logs.

### 6) IAM permissions

Your AWS identity must be able to create and read the resources used by the
example.

For NXDOMAIN examples, that typically includes:

- CloudWatch Dashboards
- CloudWatch Alarms
- Log Metric Filters
- Contributor Insights Rules

For AutoVPC examples, that typically includes:

- VPC
- Internet Gateway
- Subnets
- Route Tables
- Route Table Associations
- Route 53 Resolver query logging resources, if enabled

---

## Module source (important)

These examples use **local module paths** because they are intended to run
inside this repository.

Current local paths used in the examples:

- NXDOMAIN module: `../../modules/nxdomain`
- AutoVPC module: `../../modules/autovpc`

If you want to use Git module sources instead, replace them with:

- `github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1`
- `github.com/Codreum/terraform-aws-observability-core//modules/autovpc?ref=v1.1`

Example:

```hcl
module "codreum_dns_NX" {
  source = "github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1"
}

module "codreum_autovpc" {
  source = "github.com/Codreum/terraform-aws-observability-core//modules/autovpc?ref=v1.1"
}
```

---

## Quick start

### 1) Choose an example folder

```bash
cd example/autovpc-2az
# or:
# cd example/autovpc-1az
# cd example/autovpc-4subnets-2az
# cd example/autovpc-with-dns-vpc
# cd example/both-zone-vpc
# cd example/zone-only
# cd example/vpc-only
```

### 2) Update values in `main.tf`

At minimum, update the placeholder values in the selected example.

For NXDOMAIN examples, that usually means:

- `aws_region`
- `NX_log_group_name`
- `dns_alert_sns_arn`
- `NX_zone_id` and/or `NX_vpc_id`

For AutoVPC examples, that usually means:

- `aws_region`
- `prefix`
- `free_vpc_config`
- `tags`

### Optional: override module defaults (NXDOMAIN module quick tuning)

Each example `main.tf` includes a commented “tuning” section listing the most common override variables.
If you **uncomment and set** any of these, Terraform will use your values. If you leave them commented, the module will use its **built-in defaults**.

In `zone-only`, only Zone variables apply. In `vpc-only`, only VPC variables apply.

Example override block:

```hcl
  # ----------------------------
  # Optional tuning (overrides)
  # ----------------------------

  # Zone (Hosted Zone) tuning
  # NX_zone_nxdomain_threshold          =
  # NX_zone_nxdomain_alarm_period       =
  # NX_zone_nxdomain_eval_periods       =
  # NX_zone_topn_nxdomain               =
  # NX_zone_nxdomain_rate_threshold_pct =
  # NX_zone_anomaly_band_width          =
  # NX_zone_anomaly_eval_periods        =

  # VPC (Resolver) tuning
  # NX_vpc_nxdomain_threshold           =
  # NX_vpc_nxdomain_alarm_period        =
  # NX_vpc_nxdomain_eval_periods        =
  # NX_vpc_topn_nxdomain                =
  # NX_vpc_nxdomain_rate_threshold_pct  =
  # NX_vpc_anomaly_band_width           =
  # NX_vpc_anomaly_eval_periods         =
```

Default values (if you don’t override):

- Zone
  - `NX_zone_nxdomain_threshold` = `100`
  - `NX_zone_nxdomain_alarm_period` = `300`
  - `NX_zone_nxdomain_eval_periods` = `1`
  - `NX_zone_topn_nxdomain` = `10`
  - `NX_zone_nxdomain_rate_threshold_pct` = `10`
  - `NX_zone_anomaly_band_width` = `2.0`
  - `NX_zone_anomaly_eval_periods` = `3`

- VPC
  - `NX_vpc_nxdomain_threshold` = `200`
  - `NX_vpc_nxdomain_alarm_period` = `300`
  - `NX_vpc_nxdomain_eval_periods` = `1`
  - `NX_vpc_topn_nxdomain` = `10`
  - `NX_vpc_nxdomain_rate_threshold_pct` = `10`
  - `NX_vpc_anomaly_band_width` = `2.0`
  - `NX_vpc_anomaly_eval_periods` = `3`

### Optional: enable AutoVPC Resolver query logging

If you want AutoVPC to enable Route 53 Resolver query logging for the created
VPC, set:

- `enable_resolver_query_logging = true`
- `resolver_query_log_destination_arn = "<existing-cloudwatch-log-group-arn>"`

Example:

```hcl
  enable_resolver_query_logging      = true
  resolver_query_log_destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/resolver-query-logs"
```

> The destination CloudWatch Logs log group must already exist.

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

## What these examples deploy

Depending on the selected example, you may get one or both of the following:

### NXDOMAIN monitoring examples

- **Ops Landing** dashboard (summary + links + triage guidance)
- **Zone NXDOMAIN** dashboard (when `NX_zone_id` is set)
- **VPC NXDOMAIN** dashboard (when `NX_vpc_id` is set)
- NXDOMAIN count, rate, and anomaly alarms
- CloudWatch metric filters
- Contributor Insights rules for top offenders

### AutoVPC examples

- VPC
- Internet Gateway
- Subnets
- Route Tables
- Route Table Associations
- Optional Route 53 Resolver query logging association, if enabled

---

## Combined example note

Yes — AutoVPC and NXDOMAIN can be used together in the same Terraform root.

The combined example (autovpc-with-dns-vpc) wires the created VPC into the
NXDOMAIN module like this:

```hcl
NX_vpc_id = module.codreum_autovpc.vpc_ids["main"]
```

However, the NXDOMAIN module still requires an existing CloudWatch Logs log
group that contains Resolver query logs for that VPC. The combined example
does not create query logging destinations for you beyond associating the VPC
to the destination ARN you provide.

---

## Folder conventions

- `both-zone-vpc`
  Sets both `NX_zone_id` and `NX_vpc_id`

- `zone-only`
  Sets only `NX_zone_id`

- `vpc-only`
  Sets only `NX_vpc_id`

- `autovpc-1az`
  Creates 1 subnet in 1 AZ

- `autovpc-2az`
  Creates 2 subnets across 2 AZs

- `autovpc-4subnets-2az`
  Creates 4 subnets across 2 AZs

- `autovpc-with-dns-vpc`
  Creates a VPC using AutoVPC and passes the VPC ID into the NXDOMAIN module

---

## Troubleshooting

### 1) Dashboards show “No data”

Common causes:

- incorrect `NX_log_group_name`
- wrong AWS region
- logs are not arriving recently
- log format does not match expectations (CLF vs JSON / field names differ)
- metric filters have not matched any events yet

### 2) Alarms are stuck in “Insufficient data”

- Wait for metrics to accumulate (especially in low-traffic environments)
- Confirm the log group contains NXDOMAIN events for the selected scope
- Temporarily lower thresholds to validate wiring in a test environment

### 3) AutoVPC validation fails

Common causes:

- invalid `subnet_count`
- invalid `az_count`
- `subnet_count < az_count`
- `subnet_count` is not divisible by `az_count`
- resulting subnet mask would be larger than `/28`

### 4) Terraform cannot download the module source

If you switched from local paths to Git sources, ensure the subdirectory is correct:

- NXDOMAIN: `github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1`
- AutoVPC: `github.com/Codreum/terraform-aws-observability-core//modules/autovpc?ref=v1.1`

Re-run:

```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

---

## Notes

- These examples are designed to be copied and adapted into your own repositories.
- The AutoVPC examples are intentionally simple and follow the free-module constraints.
- The NXDOMAIN examples assume the relevant DNS logs already exist in CloudWatch Logs.
