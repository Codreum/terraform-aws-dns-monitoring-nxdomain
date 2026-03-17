<p align="center">
  <a href="https://github.com/Codreum/terraform-aws-observability-core/actions/workflows/ci.yml">
    <img
      src="https://github.com/Codreum/terraform-aws-observability-core/actions/workflows/ci.yml/badge.svg?branch=main"
      alt="CI"
    />
  </a>

  <a href="https://scorecard.dev/viewer/?uri=github.com/Codreum/terraform-aws-observability-core">
    <img
      src="https://api.scorecard.dev/projects/github.com/Codreum/terraform-aws-observability-core/badge"
      alt="OpenSSF Scorecard"
    />
  </a>

  <a href="https://www.bestpractices.dev/projects/11896">
    <img
      src="https://www.bestpractices.dev/projects/11896/badge?cachebust=20260209-1"
      alt="OpenSSF Best Practices"
    />
  </a>
</p>

<p align="center">
  <a href="https://github.com/Codreum/terraform-aws-observability-core/releases">
    <img
      src="https://img.shields.io/github/v/release/Codreum/terraform-aws-observability-core"
      alt="Release"
    />
  </a>

  <a href="https://github.com/Codreum/terraform-aws-observability-core/blob/main/LICENSE">
    <img
      src="https://img.shields.io/github/license/Codreum/terraform-aws-observability-core"
      alt="License"
    />
  </a>
</p>

<p align="center">
  <a href="https://www.codreum.com">
    <img src="../../docs/brand/logo.png" alt="Codreum" width="200" />
  </a>
</p>

<p align="center">
  <a href="https://www.codreum.com">Website</a> •
  <a href="https://www.codreum.com/products.html#zone">Upgrade</a> •
  <a href="#quickstart">Quickstart</a>
</p>

# Codreum DNS Observability (NXDOMAIN)

Detect DNS misconfigurations fast by alerting on **NXDOMAIN spikes** using
**AWS CloudWatch + Terraform**.

✅ Dashboards + alarms + anomaly detection

✅ Works with **Route 53 hosted zone query logs** + **Resolver query logs
(VPC)**

✅ Top-N triage views (domain / qtype / edge / source)

This solution is for **NXDOMAIN signals only**. **Codreum Pro** adds broader
DNS error metrics and investigation dashboards.

- **Deploy:** jump to [Quickstart](#quickstart)
- **Website:** [https://www.codreum.com](https://www.codreum.com)
- **Upgrade:** [https://www.codreum.com/products.html#zone](https://www.codreum.com/products.html#zone)

---

## Why NXDOMAIN matters

NXDOMAIN means “this name does not exist.” A spike is rarely random. It is
usually a signal that **something changed**.

Common causes:

- broken deployments (wrong domain, missing records, bad service discovery)
- misconfigured clients / endpoints (typos, outdated configs, DNS suffix issues)
- malware / beaconing attempts (random subdomains, DGA patterns)
- expired records or incorrect resolver paths

Why it is valuable:

- **Fast indicator of DNS regressions** before application errors explode
- Helps pinpoint **what** is failing and **who** is generating it
- Works for both **public hosted zones** and **private/VPC resolver** DNS

---

## Why AWS CloudWatch (in-account) instead of external DNS monitoring?

External checkers are useful, but they often miss the failures you actually care
about:

- External monitors can only test **public DNS** and a small set of resolvers.
- They cannot see **your internal resolver traffic** (VPC Resolver logs).
- They typically miss **client-specific failures** and partial outages.

This module uses **your real DNS query logs** inside AWS:

- captures failures from **real production clients**
- supports **private/internal DNS** (VPC resolver queries)
- triages by **top offending domain / qtype / edge / source IP**
- avoids shipping DNS logs to third parties

> Privacy note: this module does **not** send DNS logs to Codreum. Everything
> stays inside your AWS account.

---

## What you get (Core)

✅ Included:

1. NXDOMAIN **count** alarm (Zone + VPC)
1. NXDOMAIN **rate (%)** alarm (Zone + VPC)
1. NXDOMAIN **anomaly detection** alarms (count + rate)
1. CloudWatch dashboards:
   - Zone dashboard
   - VPC dashboard
   - Ops landing dashboard
1. Top-N triage views:
   - Zone: Top NXDOMAIN by domain / qtype / edge / source
   - VPC: Top NXDOMAIN by qname / source
1. SNS integration: alarms publish to your provided SNS topic
   (`dns_alert_sns_arn`)

🚫 Not included (Core):

1. Additional DNS error metrics (SERVFAIL / REFUSED / etc.)
1. Expanded Contributor Insights packs and dashboards beyond NXDOMAIN
1. Licensing, enforcement, premium support / SLA (Pro)
1. Log group management (Pro)

| Capability | Core | Pro |
| --- | :---: | :---: |
| NXDOMAIN static alarms + anomaly detection | ✅ | ✅ |
| NXDOMAIN Contributor Insights (Top-N rules) | ✅ | ✅ |
| NXDOMAIN dashboards (Zone / VPC baseline) | ✅ | ✅ |
| Additional DNS metrics + Contributor Insights packs | ❌ | ✅ |
| Per-zone metrics / alarm / CI toggle | ❌ | ✅ |
| Per-zone metric dashboards beyond NXDOMAIN | ❌ | ✅ |
| Per-zone Top-N dashboards (expanded) | ❌ | ✅ |
| Built-in SNS wiring presets (Email / Slack / SMS) | ❌ | ✅ |
| Log group management | ❌ | ✅ |
| Multiple zone / VPC IDs in one deployment | ❌ | ✅ |
| Advanced dashboards (Ops / Investigation / Forensics) | ❌ | ✅ |
| Licensing & enforcement | ❌ | ✅ |
| Support / SLA | ❌ | ✅ |

---

## How it works

This module:

1. reads from an existing CloudWatch Logs group containing DNS logs
   (`NX_log_group_name`)
1. creates:
   - log metric filters → custom metrics in `Codreum/DNSCI`
   - CloudWatch alarms (static + rate % + anomaly)
   - Contributor Insights rules + Logs Insights widgets (Top-N triage)
   - dashboards (zone, vpc, ops landing)
1. sends alarm notifications to your SNS topic (`dns_alert_sns_arn`)

---

## Prerequisites

1. Terraform >= 1.12
1. AWS provider >= 6.2
1. A CloudWatch Logs group already receiving DNS logs:
   - **Zone mode:** Route 53 hosted zone query logs
   - **VPC mode:** JSON resolver query logs
1. Region constraints (AWS limitation):
   - **Zone mode (`NX_zone_id`)**: Route 53 public hosted zone query logging
     requires the CloudWatch Logs log group in **`us-east-1`**.
   - **VPC mode (`NX_vpc_id`)**: Resolver query logging is **regional** and
     must be deployed in the same region as the VPC.
   - If you need both Zone + VPC monitoring across different regions, deploy
     multiple module instances.

---

## Configuration

Required:

- `prefix`
- `aws_region`
- `NX_log_group_name`
- `dns_alert_sns_arn`

Enable at least one mode:

- `NX_enable_zone = true` to create hosted-zone-scoped NXDOMAIN resources
- `NX_enable_vpc  = true` to create VPC-scoped NXDOMAIN resources

When a mode is enabled, the matching ID is required:

- `NX_zone_id` is required when `NX_enable_zone = true`
- `NX_vpc_id` is required when `NX_enable_vpc  = true`

You can enable zone monitoring, VPC monitoring, or both at the same time.
If an ID is set while its toggle is `false`, Terraform accepts it but the module ignores that value and does not create resources for that mode.

---

## Modes (Zone vs VPC)

This module can operate in either or both modes, controlled by explicit toggle variables:

- **Zone mode**: set `NX_enable_zone = true` and provide `NX_zone_id`
- **VPC mode**: set `NX_enable_vpc = true` and provide `NX_vpc_id`

The toggles are independent, so you can run:

- **Zone only**: `NX_enable_zone = true`, `NX_enable_vpc = false`
- **VPC only**: `NX_enable_zone = false`, `NX_enable_vpc = true`
- **Both together**: `NX_enable_zone = true`, `NX_enable_vpc = true`

If a mode is disabled, any value left in the corresponding ID variable is ignored.

---

## Quickstart

1. Ensure DNS query logs are flowing into CloudWatch Logs:
   - Hosted zone query logs (CLF-like)
   - Resolver query logs (JSON)
1. Copy and paste into your `main.tf`:

```hcl
module "codreum_dns_NX" {
  source = "github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1.0"

  prefix            = "acme-dev"
  aws_region        = "us-east-1"
  NX_log_group_name = "/aws/route53/resolver-query-logs"
  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789012:alerts"

  # Enable one or both modes explicitly:
  NX_enable_vpc  = true
  NX_enable_zone = true

  NX_vpc_id  = "vpc-0123456789abcdef0"
  NX_zone_id = "Z123EXAMPLE"
}
```

You can also copy the `main.tf` file from the example folder and make minimal
edits:

- replace the module source with
  `github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1.0`
- change `NX_log_group_name`, `dns_alert_sns_arn`, `NX_enable_vpc`,
  `NX_enable_zone`, `NX_vpc_id`, or `NX_zone_id` to your own resources
- change `aws_region` to the VPC region if you are using VPC mode
- if using Zone mode, make sure `aws_region = "us-east-1"`

1. Optional: this module exports dashboard URLs, alarm ARNs, and metric names
   via Terraform outputs. Add this to your own `outputs.tf` if you want:

```hcl
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
```

### Toggle examples

#### Zone only

```hcl
module "codreum_dns_NX" {
  source = "github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1.0"

  prefix            = "acme-dev"
  aws_region        = "us-east-1"
  NX_log_group_name = "/aws/route53/zone-query-logs"
  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789012:alerts"

  NX_enable_zone = true
  NX_enable_vpc  = false

  NX_zone_id = "Z123EXAMPLE"
  NX_vpc_id  = null
}
```

#### VPC only

```hcl
module "codreum_dns_NX" {
  source = "github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1.0"

  prefix            = "acme-dev"
  aws_region        = "ap-southeast-1"
  NX_log_group_name = "/aws/route53/resolver-query-logs"
  dns_alert_sns_arn = "arn:aws:sns:ap-southeast-1:123456789012:alerts"

  NX_enable_zone = false
  NX_enable_vpc  = true

  NX_zone_id = null
  NX_vpc_id  = "vpc-0123456789abcdef0"
}
```

#### Zone + VPC together

```hcl
module "codreum_dns_NX" {
  source = "github.com/Codreum/terraform-aws-observability-core//modules/nxdomain?ref=v1.1.0"

  prefix            = "acme-dev"
  aws_region        = "us-east-1"
  NX_log_group_name = "/aws/route53/resolver-query-logs"
  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789012:alerts"

  NX_enable_zone = true
  NX_enable_vpc  = true

  NX_zone_id = "Z123EXAMPLE"
  NX_vpc_id  = "vpc-0123456789abcdef0"
}
```

#### Using AutoVPC with the NXDOMAIN module

This is the recommended pattern when you want both modules in the same root
configuration:

```hcl
module "codreum_autovpc" {
  source = "../../modules/autovpc"

  prefix     = "acme-dev-"
  aws_region = "us-east-1"

  free_vpc_config = {
    main = {
      vpc_base     = "10.40.0.0"
      vpc_mask     = 24
      subnet_count = 2
      az_count     = 2
    }
  }

  enable_resolver_query_logging   = true
  resolver_query_log_destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/resolver-query-logs"
}

module "codreum_dns_NX" {
  source = "../../modules/nxdomain"

  prefix            = "acme-dev"
  aws_region        = "us-east-1"
  NX_log_group_name = "/aws/route53/resolver-query-logs"
  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789012:alerts"

  NX_enable_vpc  = true
  NX_vpc_id = module.codreum_autovpc.vpc_ids["main"]
}
```

> Note: if `NX_enable_zone` or `NX_enable_vpc` is `false`, the module does not create resources for that mode even if the corresponding ID variable is still populated.

1. Deploy:

```bash
terraform init
terraform apply
```

---

## What you will see after deploy

After `terraform apply`, you will have CloudWatch **dashboards**, **alarms**,
and **Contributor Insights** rules created in your AWS account.

> Tip: Open **CloudWatch → Dashboards** and search for your `prefix`
> (for example, `acme-dev-*`).

### 1) Dashboards (Ops / Zone / VPC)

You will get an Ops landing page plus dashboards for the modes you enabled:

- **Ops landing**: quick links + what to check first
- **Zone dashboard**: if `NX_enable_zone = true` and `NX_zone_id` is set
- **VPC dashboard**: if `NX_enable_vpc = true` and `NX_vpc_id` is set

![Dashboards](../../screenshot/dashboard3.jpg)

![Dashboards](../../screenshot/dashboard1.jpg)

![Dashboards](../../screenshot/dashboard2.jpg)

#### How to use dashboard

- If alarms fire, start at **Ops landing**, then jump into the Zone or VPC
  dashboard.
- Use **Top-N** tables to identify the top failing domains, qtype, edge, and
  source IPs.

---

### 2) Alarms (Count / Rate / Anomaly)

This module creates alarms for:

- **NXDOMAIN count** (static threshold)
- **NXDOMAIN rate (%)** (error rate)
- **anomaly detection** on both count and rate

Alarms publish to your SNS topic (`dns_alert_sns_arn`).

![Alarms](../../screenshot/alarm.jpg)

![Alarms](../../screenshot/alarm2.jpg)

![Alarms](../../screenshot/email_alert.jpg)

#### What to check

- **Count alarm**: sudden volume spike
- **Rate alarm**: NXDOMAIN becomes a larger share of total queries
- **Anomaly alarms**: unexpected behavior even if below static thresholds

---

### 3) Contributor Insights (Top-N triage)

Contributor Insights rules are used for fast Top-N analysis:

- Zone: top NXDOMAIN by **qname / qtype / edge / source**
- VPC: top NXDOMAIN by **qname / source**

![Contributor Insights](../../screenshot/CI1.jpg)

![Contributor Insights](../../screenshot/CI2.jpg)

#### How to use CI

- Open **CloudWatch → Contributor Insights**
- Filter by your `prefix`
- Start with **Top qname** and **Top source** to quickly locate the cause

---

## Upgrade to Codreum AWS Observability Pro

Codreum Pro adds:

1. more DNS metrics (SERVFAIL / REFUSED / overall error / success rate / more)
2. more pre-built metric alarms and Contributor Insights packs
3. richer dashboards with more investigation widgets
4. subscription management and support options
5. multi-zone / multi-VPC support
6. optional prebuilt alerting integrations via SNS setup
7. AutoVPC module (Pro)

Learn more:
[https://www.codreum.com/products.html#zone](https://www.codreum.com/products.html#zone)

---

## Costs (AWS billed)

This module creates CloudWatch resources that may incur AWS charges, depending
on usage, region, and free tier.

- **Contributor Insights rules** are billed by AWS.
- **Custom metrics** published under `Codreum/DNSCI` may be billed by AWS.
- **CloudWatch alarms** may be billed by AWS.

See AWS pricing:
[https://aws.amazon.com/cloudwatch/pricing/](https://aws.amazon.com/cloudwatch/pricing/)

---

## Security & data

- This module does **not** send DNS logs to Codreum.
- All analysis stays inside your AWS account.
- Alarm notifications are published only to your SNS topic.

---

## Signed releases & provenance

Every GitHub Release for this project includes **cryptographically signed
artifacts** and **SLSA provenance**.

### What is included in a release

Typical release assets include:

- `terraform-aws-observability-core-<version>.tar.gz`
- `SHA256SUMS`
- `sbom.spdx.json`
- `*.sigstore.json`
- `multiple.intoto.jsonl`

> Signatures are created using **cosign keyless signing** via GitHub Actions
> OIDC.

### Verify signatures (cosign)

1. Download a release asset and its corresponding `*.sigstore.json` bundle.
1. Verify the artifact:

```bash
VERSION=v1.1.0

cosign verify-blob \
  --bundle terraform-aws-observability-core-${VERSION}.tar.gz.sigstore.json \
  terraform-aws-observability-core-${VERSION}.tar.gz
```

Verify the other assets the same way:

```bash
cosign verify-blob --bundle SHA256SUMS.sigstore.json SHA256SUMS
cosign verify-blob --bundle sbom.spdx.json.sigstore.json sbom.spdx.json
```

### Verify provenance (SLSA)

Verify that the artifact was built from this repository and tag:

```bash
REPO="github.com/Codreum/terraform-aws-observability-core"
VERSION=v1.1.0

slsa-verifier verify-artifact \
  --provenance-path multiple.intoto.jsonl \
  --source-uri "${REPO}" \
  --source-tag "${VERSION}" \
  terraform-aws-observability-core-${VERSION}.tar.gz
```

---

## Limitations (Core)

- Designed for **one zone and/or one VPC** per deployment
- Only NXDOMAIN signals are included
- Assumes logs already exist in CloudWatch Logs

---

## Support

- Free: community support via GitHub Issues
- Contributing: see `CONTRIBUTING.md`
- Security issues: see `SECURITY.md`

Quick links:

- [Issues](https://github.com/Codreum/terraform-aws-observability-core/issues)
- [New issue](https://github.com/Codreum/terraform-aws-observability-core/issues/new/choose)
- [Contributing](https://github.com/Codreum/terraform-aws-observability-core/blob/main/CONTRIBUTING.md)
- [Security](https://github.com/Codreum/terraform-aws-observability-core/blob/main/SECURITY.md)
- [Documentation](https://www.codreum.com/docs.html)

---

## Terraform inputs and outputs

<!-- markdownlint-disable -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_contributor_insight_rule.vpc_topn_nxdomain_qname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_contributor_insight_rule) | resource |
| [aws_cloudwatch_contributor_insight_rule.vpc_topn_nxdomain_srcip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_contributor_insight_rule) | resource |
| [aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_contributor_insight_rule) | resource |
| [aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_qname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_contributor_insight_rule) | resource |
| [aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_qtype](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_contributor_insight_rule) | resource |
| [aws_cloudwatch_contributor_insight_rule.zone_topn_nxdomain_rip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_contributor_insight_rule) | resource |
| [aws_cloudwatch_dashboard.ops_dns_landing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_dashboard.vpc_dns_dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_dashboard.zone_dns_dashboard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_metric_filter.vpc_nxdomain_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.vpc_total_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.zone_nxdomain_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.zone_total_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.vpc_nxdomain_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.vpc_nxdomain_anomaly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.vpc_nxdomain_rate_anomaly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.zone_nxdomain_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.zone_nxdomain_anomaly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.zone_nxdomain_rate_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.zone_nxdomain_rate_anomaly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_route53_zone.NX_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_NX_enable_vpc"></a> [NX\_enable\_vpc](#input\_NX\_enable\_vpc) | Enable VPC-scoped NXDOMAIN resources. | `bool` | `false` | no |
| <a name="input_NX_enable_zone"></a> [NX\_enable\_zone](#input\_NX\_enable\_zone) | Enable hosted-zone-scoped NXDOMAIN resources. | `bool` | `false` | no |
| <a name="input_NX_log_group_name"></a> [NX\_log\_group\_name](#input\_NX\_log\_group\_name) | CloudWatch Logs group for Route 53 Resolver query logs. | `string` | n/a | yes |
| <a name="input_NX_vpc_anomaly_band_width"></a> [NX\_vpc\_anomaly\_band\_width](#input\_NX\_vpc\_anomaly\_band\_width) | Std-dev width for anomaly band on VPC metrics. | `number` | `null` | no |
| <a name="input_NX_vpc_anomaly_eval_periods"></a> [NX\_vpc\_anomaly\_eval\_periods](#input\_NX\_vpc\_anomaly\_eval\_periods) | Evaluation periods for VPC anomaly alarms. | `number` | `null` | no |
| <a name="input_NX_vpc_id"></a> [NX\_vpc\_id](#input\_NX\_vpc\_id) | Optional VPC to scope NXDOMAIN client insights & alarm. | `string` | `null` | no |
| <a name="input_NX_vpc_nxdomain_alarm_period"></a> [NX\_vpc\_nxdomain\_alarm\_period](#input\_NX\_vpc\_nxdomain\_alarm\_period) | n/a | `number` | `null` | no |
| <a name="input_NX_vpc_nxdomain_eval_periods"></a> [NX\_vpc\_nxdomain\_eval\_periods](#input\_NX\_vpc\_nxdomain\_eval\_periods) | n/a | `number` | `null` | no |
| <a name="input_NX_vpc_nxdomain_rate_threshold_pct"></a> [NX\_vpc\_nxdomain\_rate\_threshold\_pct](#input\_NX\_vpc\_nxdomain\_rate\_threshold\_pct) | n/a | `number` | `null` | no |
| <a name="input_NX_vpc_nxdomain_threshold"></a> [NX\_vpc\_nxdomain\_threshold](#input\_NX\_vpc\_nxdomain\_threshold) | n/a | `number` | `null` | no |
| <a name="input_NX_vpc_topn_nxdomain"></a> [NX\_vpc\_topn\_nxdomain](#input\_NX\_vpc\_topn\_nxdomain) | n/a | `number` | `null` | no |
| <a name="input_NX_zone_anomaly_band_width"></a> [NX\_zone\_anomaly\_band\_width](#input\_NX\_zone\_anomaly\_band\_width) | Std-dev width for anomaly band on Zone metrics (e.g., 2.0 ≈ ~95%). | `number` | `null` | no |
| <a name="input_NX_zone_anomaly_eval_periods"></a> [NX\_zone\_anomaly\_eval\_periods](#input\_NX\_zone\_anomaly\_eval\_periods) | Evaluation periods for Zone anomaly alarms. | `number` | `null` | no |
| <a name="input_NX_zone_id"></a> [NX\_zone\_id](#input\_NX\_zone\_id) | Optional hosted zone (Zxxxxxxxx) to scope 'top NXDOMAIN names'. | `string` | `null` | no |
| <a name="input_NX_zone_nxdomain_alarm_period"></a> [NX\_zone\_nxdomain\_alarm\_period](#input\_NX\_zone\_nxdomain\_alarm\_period) | n/a | `number` | `null` | no |
| <a name="input_NX_zone_nxdomain_eval_periods"></a> [NX\_zone\_nxdomain\_eval\_periods](#input\_NX\_zone\_nxdomain\_eval\_periods) | n/a | `number` | `null` | no |
| <a name="input_NX_zone_nxdomain_rate_threshold_pct"></a> [NX\_zone\_nxdomain\_rate\_threshold\_pct](#input\_NX\_zone\_nxdomain\_rate\_threshold\_pct) | n/a | `number` | `null` | no |
| <a name="input_NX_zone_nxdomain_threshold"></a> [NX\_zone\_nxdomain\_threshold](#input\_NX\_zone\_nxdomain\_threshold) | n/a | `number` | `null` | no |
| <a name="input_NX_zone_topn_nxdomain"></a> [NX\_zone\_topn\_nxdomain](#input\_NX\_zone\_topn\_nxdomain) | n/a | `number` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | n/a | `string` | n/a | yes |
| <a name="input_dns_alert_sns_arn"></a> [dns\_alert\_sns\_arn](#input\_dns\_alert\_sns\_arn) | SNS ARN for alarms. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarms"></a> [alarms](#output\_alarms) | Alarm names and ARNs for integrating with other systems. |
| <a name="output_contributor_insights_rules"></a> [contributor\_insights\_rules](#output\_contributor\_insights\_rules) | Contributor Insights rule names (Top-N) created by this module. |
| <a name="output_dashboards"></a> [dashboards](#output\_dashboards) | CloudWatch dashboard names and console URLs. |
| <a name="output_enabled"></a> [enabled](#output\_enabled) | Which modes are enabled in this deployment. |
| <a name="output_metrics"></a> [metrics](#output\_metrics) | Custom metric namespace and metric names created by this module. |
<!-- END_TF_DOCS -->
<!-- markdownlint-restore -->