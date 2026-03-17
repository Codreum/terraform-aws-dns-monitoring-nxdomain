<p align="center">
  <a href="https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/actions/workflows/ci.yml">
    <img
      src="https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/actions/workflows/ci.yml/badge.svg?branch=main"
      alt="CI"
    />
  </a>

  <a href="https://scorecard.dev/viewer/?uri=github.com/Codreum/terraform-aws-dns-monitoring-nxdomain">
    <img
      src="https://api.scorecard.dev/projects/github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/badge"
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
  <a href="https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/releases">
    <img
      src="https://img.shields.io/github/v/release/Codreum/terraform-aws-dns-monitoring-nxdomain"
      alt="Release"
    />
  </a>

  <a href="https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/blob/main/LICENSE">
    <img
      src="https://img.shields.io/github/license/Codreum/terraform-aws-dns-monitoring-nxdomain"
      alt="License"
    />
  </a>
</p>

<p align="center">
  <a href="https://www.codreum.com">
    <img src="docs/brand/logo.png" alt="Codreum" width="200" />
  </a>
</p>

<p align="center">
  <a href="https://www.codreum.com">Website</a> •
  <a href="https://www.codreum.com/products.html#zone">Upgrade</a> •
  <a href="#available-modules">Modules</a>
</p>

# Codreum Terraform AWS Modules

This repository contains Codreum Terraform modules for AWS DNS monitoring and
lightweight VPC provisioning.

## Available modules

### 1. DNS Monitoring — NXDOMAIN (Free)

Detect DNS misconfigurations fast by alerting on **NXDOMAIN spikes** using
**AWS CloudWatch + Terraform**.

- Module path: `//modules/nxdomain`
- Module docs: [`modules/nxdomain/README.md`](./modules/nxdomain/README.md)

Example:

```hcl
module "codreum_dns_nx" {
  source = "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules/nxdomain?ref=v1.1.0"

  prefix            = "acme-dev"
  aws_region        = "us-east-1"
  NX_log_group_name = "/aws/route53/resolver-query-logs"
  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789012:alerts"

  NX_vpc_id  = "vpc-0123456789abcdef0"
  NX_zone_id = "Z123EXAMPLE"
}
```

### 2. AutoVPC (Free)

Create a constrained, low-complexity VPC layout for free/basic deployments.

- Module path: `//modules/autovpc`
- Module docs: [`modules/autovpc/README.md`](./modules/autovpc/README.md)

Supports optional Route 53 Resolver query logging for the created VPC when
you provide an existing CloudWatch Logs log group ARN.

Example:

```hcl
module "codreum_autovpc" {
  source = "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules/autovpc?ref=v1.1.0"

  prefix     = "acme-dev-"
  aws_region = "us-east-1"

  free_vpc_config = {
    main = {
      vpc_base     = "10.10.0.0"
      vpc_mask     = 24
      subnet_count = 2
      az_count     = 2
    }
  }

  enable_resolver_query_logging   = true
  resolver_query_log_destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/resolver-query-logs"
}
```

## Module comparison

### NXDOMAIN

| Capability | Free | Pro |
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
| Licensing and enforcement | ❌ | ✅ |
| Support / SLA | ❌ | ✅ |

### AutoVPC

| Capability | Free | Pro |
| --- | :---: | :---: |
| Single VPC deployment | ✅ | ✅ |
| Supported AZ count | 1 or 2 only | 1, 2, or 4 |
| Supported subnet_count | 1, 2, or 4 only | 1 to 64 (power-of-2 options) |
| Optional Resolver query logging enablement | ✅ | ✅ |
| CloudWatch Logs log group creation for DNS logs | ❌ manual ARN required | Depends on Pro packaging |
| NAT support | ❌ | ✅ |
| Basic subnet auto-splitting | ✅ | ✅ |
| Basic route table setup | ✅ | ✅ |
| Internet Gateway wiring | ✅ | ✅ |
| IPv6 / dual-stack controls | ❌ | ✅ |
| Flow logs | ❌ | ✅ |
| Gateway endpoints | ❌ | ✅ |
| Interface endpoints | ❌ | ✅ |
| DNS firewall integration | ❌ | ✅ |
| Internet Monitor integration | ❌ | ✅ |
| VPC / subnet metric alarms | ❌ | ✅ |
| License validation / enforcement | ❌ | ✅ |
| License watcher + alerts | ❌ | ✅ |
| Support / SLA | ❌ | ✅ |

## Repository structure

```text
.
├── README.md
├── example/
├── modules/
│   ├── nxdomain/
│   │   └── README.md
│   └── autovpc/
│       └── README.md
└── docs/
```

## Versioning

This repository uses Git tags for releases.

When multiple modules live in the same repository, the tag versions the whole
repository snapshot. Both `nxdomain` and `autovpc` should therefore be pinned
using the same repo tag.

Examples:

```hcl
source = "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules/nxdomain?ref=v1.1.0"
```

```hcl
source = "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules/autovpc?ref=v1.1.0"
```

## Free vs Pro

This repository contains the **free** NXDOMAIN and AutoVPC modules.

Codreum Pro adds broader DNS monitoring and advanced VPC capabilities as a paid
package. The current plan is for **DNS Pro** and **AutoVPC Pro** to live
together in the Pro repository/package.

Planned Pro package positioning:

- **Codreum DNS Pro**
- **Codreum AutoVPC Pro**
- bundled together as the **USD 49.99** package

See the product page for upgrade information:

- [https://www.codreum.com/products.html#zone](https://www.codreum.com/products.html#zone)

## Examples

This repository includes examples for both modules, including a combined
AutoVPC + NXDOMAIN example.

Example areas include:

- `example/both-zone-vpc`
- `example/zone-only`
- `example/vpc-only`
- `example/autovpc-1az`
- `example/autovpc-2az`
- `example/autovpc-4subnets-2az`
- `example/autovpc-with-dns-vpc`

> Note: the CloudWatch Logs log group must already exist. The AutoVPC free
> module does not create the log group for DNS logs.

For module-specific usage and inputs, see:

- [`modules/nxdomain/README.md`](./modules/nxdomain/README.md)
- [`modules/autovpc/README.md`](./modules/autovpc/README.md)

## Using both modules together

Yes — both modules can be used in the same Terraform root configuration.

Typical combined flow:

- AutoVPC creates the VPC
- AutoVPC optionally enables Resolver query logging for that VPC
- NXDOMAIN consumes the existing CloudWatch Logs log group by name
- NXDOMAIN monitors the VPC by using the VPC ID produced by AutoVPC

Important note:

- AutoVPC does not create the CloudWatch Logs log group for DNS logs
- NXDOMAIN also does not create that log group in the free module
- if you enable Resolver query logging, you must manually supply an existing CloudWatch Logs log group ARN to AutoVPC
- NXDOMAIN must be pointed at that existing log group by name

## Support

- Free: community support via GitHub Issues
- Security issues: see `SECURITY.md`
- Contributions: see `CONTRIBUTING.md`

Quick links:

- [Issues](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/issues)
- [New issue](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/issues/new/choose)
- [Contributing](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/blob/main/CONTRIBUTING.md)
- [Security](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/blob/main/SECURITY.md)
- [Documentation](https://www.codreum.com/docs.html)
