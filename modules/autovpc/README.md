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
    <img src="../../docs/brand/logo.png" alt="Codreum" width="200" />
  </a>
</p>

<p align="center">
  <a href="https://www.codreum.com">Website</a> •
  <a href="https://www.codreum.com/products.html#zone">Upgrade</a> •
  <a href="#quickstart">Quickstart</a>
</p>

# Codreum AutoVPC (Free)

Create a constrained AWS VPC layout fast using **Terraform**.

✅ Creates a VPC, Internet Gateway, subnets, route tables, and associations

✅ Supports **1 VPC per deployment**

✅ Supports simple subnet / AZ choices for free/basic environments

✅ Can optionally enable **Route 53 Resolver query logging** for the created VPC

This solution is for **free/basic VPC deployment**. **Codreum Pro** adds
broader VPC capabilities, license handling, and richer deployment options.

- **Deploy:** jump to [Quickstart](#quickstart)
- **Website:** [https://www.codreum.com](https://www.codreum.com)
- **Upgrade:** [https://www.codreum.com/products.html#zone](https://www.codreum.com/products.html#zone)

---

## Why AutoVPC matters

Creating a VPC is easy. Creating one that stays **simple**, **repeatable**, and
**safe for small environments** is harder than it looks.

Common use cases:

- sandbox and evaluation environments
- lightweight internal apps
- dev / test accounts that need a fast network baseline
- repeatable proof-of-concept deployments

Why this module is useful:

- reduces manual VPC setup drift
- provides a constrained layout for predictable deployment
- keeps the free version intentionally low-complexity
- gives a clean upgrade path to Codreum Pro

---

## Why use this module instead of hand-building VPC resources every time?

Hand-built VPCs often drift over time:

- subnet splits become inconsistent between environments
- route table behavior differs by account or engineer
- basic tagging is forgotten
- small environments end up over-designed

This module uses a **constrained free model**:

- one VPC per deployment
- fixed allowed subnet counts: **1, 2, or 4**
- fixed allowed AZ counts: **1 or 2**
- automatic subnet CIDR derivation from your base CIDR
- route table creation and subnet association included
- optional Route 53 Resolver query logging for the created VPC

> Simplicity note: this free module is intentionally opinionated and does not
> include NAT, advanced endpoint packs, richer VPC controls, or licensing
> features.

---

## What you get (Free)

✅ Included:

1. 1 VPC per deployment
2. Internet Gateway
3. subnet creation from a base CIDR
4. route table creation per subnet
5. route table associations
6. basic output map for VPC IDs and subnet plan
7. validation for supported subnet and AZ combinations
8. optional Route 53 Resolver query logging association for the created VPC

🚫 Not included (Free):

1. CloudWatch Logs log group creation for DNS logs
2. NAT gateway support
3. dual-stack / IPv6 controls
4. VPC flow logs
5. gateway or interface endpoints
6. DNS firewall integration
7. Internet Monitor integration
8. VPC / subnet metric alarms
9. license validation / enforcement
10. premium support / SLA
11. multi-VPC free deployment

| Capability                                      | Free                  | Pro                          |
| ----------------------------------------------- | :-------------------: | :--------------------------: |
| Single VPC deployment                           | ✅                     | ✅                            |
| Supported AZ count                              | 1 or 2 only           | 1, 2, or 4                   |
| Supported subnet_count                          | 1, 2, or 4 only       | 1 to 64 (power-of-2 options) |
| Optional Resolver query logging enablement      | ✅                     | ✅                            |
| CloudWatch Logs log group creation for DNS logs | ❌ manual ARN required | Depends on Pro packaging     |
| NAT support                                     | ❌                     | ✅                            |
| Basic subnet auto-splitting                     | ✅                     | ✅                            |
| Basic route table setup                         | ✅                     | ✅                            |
| Internet Gateway wiring                         | ✅                     | ✅                            |
| IPv6 / dual-stack controls                      | ❌                     | ✅                            |
| Flow logs                                       | ❌                     | ✅                            |
| Gateway endpoints                               | ❌                     | ✅                            |
| Interface endpoints                             | ❌                     | ✅                            |
| DNS firewall integration                        | ❌                     | ✅                            |
| Internet Monitor integration                    | ❌                     | ✅                            |
| VPC / subnet metric alarms                      | ❌                     | ✅                            |
| License validation / enforcement                | ❌                     | ✅                            |
| License watcher + alerts                        | ❌                     | ✅                            |
| Support / SLA                                   | ❌                     | ✅                            |

---

## How it works

This module:

1. reads your requested VPC base CIDR and mask from `free_vpc_config`
2. validates the supported free-edition combinations
3. creates:
   - VPC
   - Internet Gateway
   - subnets
   - route tables
   - route table associations
4. optionally creates:
   - Route 53 Resolver query log config
   - Route 53 Resolver query log config association to the created VPC
5. exports:
   - `vpc_ids`
   - `subnet_plan`
   - `resolver_query_log_config_id`
   - `resolver_query_log_config_arn`

---

## Prerequisites

1. Terraform >= 1.12
2. AWS provider compatible with your deployment
3. a target AWS region
4. a valid `free_vpc_config` input
5. if enabling Resolver query logging:
   - an existing CloudWatch Logs log group ARN to use as the destination

---

## Configuration

Required:

- `prefix`
- `aws_region`
- `free_vpc_config`

Optional:

- `tags`
- `enable_resolver_query_logging`
- `resolver_query_log_destination_arn`
- `resolver_query_log_config_name`

Free-edition rules:

- supports a maximum of **1 VPC**
- `subnet_count` must be **1**, **2**, or **4**
- `az_count` must be **1** or **2**
- `subnet_count` must be **greater than or equal to** `az_count`
- `subnet_count` must be **divisible by** `az_count`
- the resulting subnet mask must not exceed **/28**

Resolver query logging rules:

- set `enable_resolver_query_logging = true` to enable it
- when enabled, `resolver_query_log_destination_arn` must be provided
- this module does **not** create the CloudWatch Logs log group for you
- the destination log group must already exist

---

## Modes

This module is intentionally simple and uses one free deployment model.

Operationally, you can use it in either of these shapes:

- **single-AZ layout**: `az_count = 1`
- **two-AZ layout**: `az_count = 2`

Common valid combinations include:

- `subnet_count = 1`, `az_count = 1`
- `subnet_count = 2`, `az_count = 1`
- `subnet_count = 2`, `az_count = 2`
- `subnet_count = 4`, `az_count = 1`
- `subnet_count = 4`, `az_count = 2`

---

## Quickstart

### Basic AutoVPC deployment

```hcl
module "codreum_autovpc" {
  source = "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules/autovpc?ref=v1.1.0"

  prefix     = "acme-dev-"
  aws_region = "ap-southeast-1"

  free_vpc_config = {
    main = {
      vpc_base     = "10.10.0.0"
      vpc_mask     = 24
      subnet_count = 2
      az_count     = 2
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### AutoVPC with Resolver query logging enabled

```hcl
module "codreum_autovpc" {
  source = "github.com/Codreum/terraform-aws-dns-monitoring-nxdomain//modules/autovpc?ref=v1.1.0"

  prefix     = "acme-dev-"
  aws_region = "ap-southeast-1"

  free_vpc_config = {
    main = {
      vpc_base     = "10.10.0.0"
      vpc_mask     = 24
      subnet_count = 2
      az_count     = 2
    }
  }

  enable_resolver_query_logging      = true
  resolver_query_log_destination_arn = "arn:aws:logs:ap-southeast-1:123456789012:log-group:/aws/route53/resolver-query-logs"

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Using AutoVPC with the NXDOMAIN module

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

  enable_resolver_query_logging      = true
  resolver_query_log_destination_arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/route53/resolver-query-logs"
}

module "codreum_dns_NX" {
  source = "../../modules/nxdomain"

  prefix            = "acme-dev"
  aws_region        = "us-east-1"
  NX_log_group_name = "/aws/route53/resolver-query-logs"
  dns_alert_sns_arn = "arn:aws:sns:us-east-1:123456789012:alerts"

  NX_vpc_id = module.codreum_autovpc.vpc_ids["main"]
}
```

1. Optional: export the module outputs in your own `outputs.tf`:

```hcl
output "autovpc_vpc_ids" {
  value = module.codreum_autovpc.vpc_ids
}

output "autovpc_subnet_plan" {
  value = module.codreum_autovpc.subnet_plan
}

output "autovpc_resolver_query_log_config_id" {
  value = module.codreum_autovpc.resolver_query_log_config_id
}

output "autovpc_resolver_query_log_config_arn" {
  value = module.codreum_autovpc.resolver_query_log_config_arn
}
```

2. Deploy:

```bash
terraform init
terraform apply
```

---

## What you will see after deploy

After `terraform apply`, you will have the following created in your AWS
account:

- one VPC
- one Internet Gateway
- one or more subnets
- one route table per subnet
- one route table association per subnet

If Resolver query logging is enabled, you will also get:

- one Route 53 Resolver query log config
- one Route 53 Resolver query log config association bound to the created VPC

The module also exports a subnet plan so you can quickly see:

- subnet CIDR
- selected AZ
- whether the subnet gets an Internet Gateway default route
- subnet and VPC IDs

### Routing behavior

This free module uses a simple route model:

- if `az_count == subnet_count`, every subnet gets an Internet Gateway default
  route
- otherwise, only the **first subnet in each AZ** gets the default route

That keeps the free module deterministic while avoiding more advanced NAT-based
designs.

---

## Upgrade to Codreum Pro

Codreum Pro adds richer VPC capabilities.

The Pro package currently includes:

1. license validation
2. a license watcher Lambda
3. SNS notifications and DynamoDB-backed license state
4. a Pro `autovpc` module
5. NAT support
6. broader subnet and AZ options
7. IPv6 / dual-stack controls
8. VPC flow logs
9. gateway and interface endpoints
10. DNS firewall options
11. Internet Monitor options
12. VPC and subnet metric alarms

Planned packaging:

- **Codreum DNS Pro**
- **Codreum AutoVPC Pro**
- together in the **USD 49.99** Pro package

Upgrade info:
[https://www.codreum.com/products.html#zone](https://www.codreum.com/products.html#zone)

---

## Costs (AWS billed)

This module creates AWS networking resources that may incur AWS charges.

Typical billable resources include:

- VPC-related resources managed by AWS
- Internet Gateway usage as applicable
- any downstream AWS services attached to the VPC
- Route 53 Resolver query logging resources if enabled
- CloudWatch Logs ingestion/storage for DNS logs if query logging is enabled

Free edition intentionally avoids NAT gateway charges by not creating NAT.

Always check AWS pricing for your region and usage pattern.

---

## Security & data

- This module does **not** send VPC configuration data to Codreum.
- All resources are created directly in your AWS account.
- If Resolver query logging is enabled, DNS query logs are sent to the
  destination you provide.
- This module does **not** create or manage the log group contents beyond
  associating query logging to the destination ARN you supply.

---

## Limitations (Free)

- maximum **1 VPC** per deployment
- supports only `az_count = 1 or 2`
- supports only `subnet_count = 1, 2, or 4`
- `subnet_count` must be greater than or equal to `az_count`
- `subnet_count` must be divisible by `az_count`
- Route 53 Resolver query logging requires a manually supplied destination log
  group ARN
- this module does **not** create the CloudWatch Logs log group for DNS logs
- no NAT support
- no IPv6 controls
- no flow logs
- no gateway or interface endpoints
- no DNS firewall integration
- no Internet Monitor integration
- no VPC / subnet metric alarms
- no license management
- designed for simple baseline environments, not complex production networking

---

## Support

- Free: community support via GitHub Issues
- Contributing: see `CONTRIBUTING.md`
- Security issues: see `SECURITY.md`

Quick links:

- [Issues](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/issues)
- [New issue](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/issues/new/choose)
- [Contributing](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/blob/main/CONTRIBUTING.md)
- [Security](https://github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/blob/main/SECURITY.md)
- [Documentation](https://www.codreum.com/docs.html)

---

## Terraform inputs and outputs

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_internet_gateway.free_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route53_resolver_query_log_config.free_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config) | resource |
| [aws_route53_resolver_query_log_config_association.free_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_query_log_config_association) | resource |
| [aws_route_table.free_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.free_rt_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.free_sub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.free_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Region for free VPC deployment | `string` | n/a | yes |
| <a name="input_enable_resolver_query_logging"></a> [enable\_resolver\_query\_logging](#input\_enable\_resolver\_query\_logging) | Enable Route 53 Resolver query logging for the created VPC. | `bool` | `false` | no |
| <a name="input_free_vpc_config"></a> [free\_vpc\_config](#input\_free\_vpc\_config) | Free VPC configuration map (supports max 1 VPC) | <pre>map(object({<br/>    vpc_base     = string<br/>    vpc_mask     = number<br/>    subnet_count = number<br/>    az_count     = number<br/>  }))</pre> | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_resolver_query_log_config_name"></a> [resolver\_query\_log\_config\_name](#input\_resolver\_query\_log\_config\_name) | Optional name for the Route 53 Resolver query log config. | `string` | `null` | no |
| <a name="input_resolver_query_log_destination_arn"></a> [resolver\_query\_log\_destination\_arn](#input\_resolver\_query\_log\_destination\_arn) | Destination ARN for Route 53 Resolver query logs. Usually a CloudWatch Logs log group ARN. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resolver_query_log_config_arn"></a> [resolver\_query\_log\_config\_arn](#output\_resolver\_query\_log\_config\_arn) | n/a |
| <a name="output_resolver_query_log_config_id"></a> [resolver\_query\_log\_config\_id](#output\_resolver\_query\_log\_config\_id) | n/a |
| <a name="output_subnet_plan"></a> [subnet\_plan](#output\_subnet\_plan) | n/a |
| <a name="output_vpc_ids"></a> [vpc\_ids](#output\_vpc\_ids) | n/a |
<!-- END_TF_DOCS -->
