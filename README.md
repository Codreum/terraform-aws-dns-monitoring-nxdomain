## Codreum DNS Monitoring (Free)

Detect DNS misconfigurations fast by alerting on **NXDOMAIN spikes** using CloudWatch + Terraform.

✅ Dashboards + alarms + anomaly detection  
✅ Works with **Route 53 hosted zone logs** + **Resolver query logs (VPC)**  
✅ Top-N triage views (domain / qtype / edge / source)

Free includes NXDOMAIN signals only. **Codreum Pro** adds broader DNS error metrics and investigation dashboards.

- **Deploy:** jump to [Quickstart](#quickstart)  
- **Website:** Codreum (link)  
- **Upgrade:** Codreum DNS Monitoring Pro (link)

## Why NXDOMAIN matters
NXDOMAIN spikes often indicate:
- broken deployments (wrong domain, missing records)
- misconfigured clients / endpoints
- malware or beaconing attempts
- expired records or incorrect resolver paths

This module helps you detect these quickly and investigate using Top-N breakdowns.



## What you get (Free)

✅ Included:

1. NXDOMAIN count alarm (Zone + VPC)
2. NXDOMAIN rate (%) alarm (Zone + VPC)
3. Anomaly detection alarms (count + rate)
4. CloudWatch dashboards:
   - Zone dashboard
   - VPC dashboard
   - Ops landing dashboard
5. Top-N triage views
- Zone: Top NXDOMAIN by domain/qtype/edge/source
- VPC: Top NXDOMAIN by qname/source
6. SNS integration: alarms publish to your provided SNS topic (dns_alert_sns_arn)


🚫 Not included (Free):
1. Additional DNS error metrics (SERVFAIL/REFUSED/etc.)
2. Expanded Contributor Insights packs and dashboards beyond NXDOMAIN
3. Licensing, enforcement, premium support / SLA (Pro)
4. Log group management
(Available in Codreum Pro.)

| Capability | Free | Pro |
|---|:---:|:---:|
| NXDOMAIN static alarms + anomaly detection | ✅ | ✅ |
| NXDOMAIN Contributor Insights (Top-N rules) | ✅ | ✅ |
| NXDOMAIN dashboards (Zone/VPC baseline) | ✅ | ✅ |
| Additional DNS metrics + Contributor Insights packs (SERVFAIL/REFUSED/etc.) | ❌ | ✅ |
| Per zone metrics/Alarm/CI toggle | ❌ | ✅ |
| Per-zone metric dashboards (beyond NXDOMAIN) | ❌ | ✅ |
| Per-zone Top-N dashboards (expanded) | ❌ | ✅ |
| Built-in SNS wiring presets (Email / Slack / SMS) | ❌ | ✅ |
| Log group management | ❌ | ✅ |
| Multiple zone/VPC IDs in one deployment | ❌ | ✅ |
| Advanced dashboards (Ops landing / Investigation / Forensics) | ❌ | ✅ |
| Licensing & enforcement | ❌ | ✅ |
| Support / SLA | ❌ | ✅ |


## How it works (simple architecture)

This module:
1. reads from an existing CloudWatch Logs group containing DNS logs (free_log_group_name)
2  creates:
   - Log metric filters → custom metrics in `Codreum/DNSCI`
   - CloudWatch alarms (static + rate % + anomaly)
   - Contributor Insights rules + Logs Insights widgets (Top-N triage)
   - Dashboards (zone, vpc, ops landing)
3. sends alarm notifications to your SNS topic (dns_alert_sns_arn)


## Prerequisites

1. Terraform >= 1.7
2. AWS provider >= 6.2
3. CloudWatch Logs group already receiving DNS logs:
  - Zone mode: Route 53 hosted zone query logs (CLF-like) (fields include hosted_zone_id, rcode, qname, etc.)
  - VPC mode: JSON resolver query logs (fields include vpc_id, rcode, srcaddr, qname, etc.)


## Configuration

1. Required
  - prefix
  - aws_region
  - product_code
  - free_log_group_name
  - dns_alert_sns_arn
  - Provide at least one:
     - free_zone_id (enables zone alarms/dashboards/widgets)
     - free_vpc_id (enables vpc alarms/dashboards/widgets)

You can enable zone monitoring, VPC monitoring, or both in the same deployment.

## Inputs (high level)

| Input | Required | Description |
|---|:---:|---|
| `free_log_group_name` | ✅ | CloudWatch Logs group that already receives DNS logs |
| `dns_alert_sns_arn` | ✅ | SNS topic ARN for alarm notifications |
| `free_zone_id` | ✅* | Enable hosted zone mode (choose zone or VPC or both) |
| `free_vpc_id` | ✅* | Enable VPC mode (choose zone or VPC or both) |


2. Optional :
  - Threshold knobs (count/rate, period, eval periods)
  - Anomaly knobs (*_anomaly_band_width, *_anomaly_eval_periods)

3. Defaults
This module ships with sane defaults:
  - Zone NXDOMAIN threshold: 100 / period
  - VPC NXDOMAIN threshold: 200 / period
  - NXDOMAIN rate threshold: 10%
(Override via variables if needed.)

## Quickstart
1. Ensure DNS query logs are flowing into CloudWatch Logs:
   - Hosted zone query logs (CLF-like)
   - Resolver query logs (JSON)
   
2. Copy paste this into your main.tf 

```hcl
module "codreum_dns_free" {
  source = "github.com/<org>/<repo>//modules/free?ref=v0.1.0"

  prefix             = "acme-dev"
  aws_region         = "us-east-1"
  product_code       = "dnscif"
  free_log_group_name = "/aws/route53/resolver-query-logs"  # must match your cloudwatch log group name
  dns_alert_sns_arn   = "arn:aws:sns:us-east-1:123456789012:alerts"  # change to your own SNS ARN
  free_vpc_id  = "vpc-0123456789abcdef0"    # change to the vpc id you want to monitor
  free_zone_id = "Z123EXAMPLE"  # change to the zone id you want to monitor
}
```

3. (optional) this module exports dashboard URLs, alarm ARNs, and metric names via Terraform outputs. If you want the output, paste this code too
```hcl
output "dns_free_enabled" {
  value = module.dnsci.enabled
}

output "dns_free_dashboards" {
  value = module.dnsci.dashboards
}

output "dns_free_alarms" {
  value = module.dnsci.alarms
}

output "dns_free_metrics" {
  value = module.dnsci.metrics
}

output "dns_free_ci_rules" {
  value = module.dnsci.contributor_insights_rules
}
```

4. Deploy :

terraform init

terraform apply


## What you’ll see after deploy

After `terraform apply`, you’ll have CloudWatch **dashboards**, **alarms**, and **Contributor Insights** rules created in your AWS account.

> Tip: Open **CloudWatch → Dashboards** and search for your `prefix` (e.g., `acme-dev-free-*`).

### 1) Dashboards (Ops / Zone / VPC)

You’ll get an Ops landing page plus dashboards for the modes you enabled:

- **Ops landing**: quick links + “what to check first”
- **Zone dashboard** (if `free_zone_id` is set): NXDOMAIN count, rate %, anomaly band, Top-N breakdowns
- **VPC dashboard** (if `free_vpc_id` is set): NXDOMAIN count, rate %, anomaly band, Top-N by source/qname

![Dashboards](./screenshot/dashboard3.jpg)

![Dashboards](./screenshot/dashboard1.jpg)

![Dashboards](./screenshot/dashboard2.jpg)

**How to use**
- If alarms fire, start at **Ops landing**, then jump into **Zone/VPC** dashboard.
- Use **Top-N** tables to identify the top failing domains, qtype, edge, and source IPs.

---

### 2) Alarms (Count / Rate / Anomaly)

This module creates alarms for:
- **NXDOMAIN count** (static threshold)
- **NXDOMAIN rate (%)** (error rate)
- **Anomaly detection** on both count and rate

Alarms publish to your SNS topic (`dns_alert_sns_arn`).

![Alarms](./screenshot/alarm.jpg)

![Alarms](./screenshot/alarm2.jpg)

![Alarms](./screenshot/email_alert.jpg)

**What to check**
- **Count alarm**: sudden volume spike (often broken deploy / client loop)
- **Rate alarm**: NXDOMAIN becoming a larger share of total queries
- **Anomaly alarms**: unexpected behavior even if below static thresholds

---

### 3) Contributor Insights (Top-N triage)

Contributor Insights rules are used for “Top-N” analysis (fast triage):
- Zone: top NXDOMAIN by **qname / qtype / edge / source**
- VPC: top NXDOMAIN by **qname / source**

![Contributor Insights](./screenshot/CI1.jpg)

![Contributor Insights](./screenshot/CI2.jpg)

**How to use**
- Open **CloudWatch → Contributor Insights**
- Filter by your `prefix`
- Start with **Top qname** and **Top source** to quickly locate the cause



## Upgrade to Codreum Pro

Codreum Pro adds:
1. More DNS metrics (SERVFAIL/REFUSED/overall error, success rate, etc.)
2. More pre-built metric alarms, contributor insight packs
3. More dashboards with richer, opinionated investigation widgets
4. subscription management & support options
5. Multi-zone / multi-vpc support
6. Optional prebuilt alerting integrations (email / Slack / SMS) via SNS setup

Learn more: Codreum DNS Monitoring Pro (link)

## Costs (AWS billed)

This module creates CloudWatch resources that may incur AWS charges, depending on usage, region, and free tier.

- **Contributor Insights rules**: used for Top-N analysis (e.g., top NXDOMAIN domains/clients). Charged per rule and usage.
- **Custom metrics**: metric filters publish metrics under `Codreum/DNSCI` (e.g., `ZoneNXDOMAIN`, `VpcNXDOMAIN`). Custom metrics may be billed by AWS.
- **CloudWatch alarms**: static threshold, rate (%), and anomaly alarms may be billed by AWS.

See AWS pricing: https://aws.amazon.com/cloudwatch/pricing/

## Security & data
- This module does **not** send DNS logs to Codreum.
- All analysis happens inside your AWS account using CloudWatch Logs / Metrics / Contributor Insights.
- Alarm notifications are published only to your SNS topic.

## Limitations (Free)
- Designed for **one zone and/or one VPC** per deployment.
- Only NXDOMAIN signals are included.
- Assumes logs already exist in CloudWatch Logs.


## Support
- Free: community support via GitHub Issues  
- Pro: SLA-backed support options (link)

