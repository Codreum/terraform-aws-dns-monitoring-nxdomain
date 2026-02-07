# Security Policy

## Reporting a vulnerability

If you discover a security issue, please **do not** open a public GitHub issue.

Instead, report it privately:

* Email: [**support@codreum.com**](mailto:support@codreum.com)

Please include:

* A clear description of the issue
* Impact (what could happen)
* Steps to reproduce
* Affected versions
* Any suggested fix/patch (if you have one)

We will acknowledge receipt and work with you on an appropriate fix timeline.

## Disclosure \& response timelines

We follow **coordinated vulnerability disclosure**.

* **Acknowledgement:** within **2 business days**
* **Initial triage:** within **5 business days** (confirm impact, severity, and affected versions)
* **Remediation target:** for confirmed vulnerabilities, we aim to provide a fix or mitigation within **90 days**, or share a concrete status update if more time is required
* **Ongoing updates:** we will provide progress updates at least every **14 days** while a fix is in progress
* **Public disclosure:** we prefer disclosure **after a fix is available** (or mitigations are documented), coordinated with the reporter

If you believe active exploitation is occurring, please note that in your report so we can prioritize.

## Supported versions

Security fixes are provided for:

* The latest released version
* Recent minor versions where feasible

## Scope

This repo contains Terraform infrastructure code (no runtime service). Security issues may include:

* Credential exposure risk
* Insecure defaults
* IAM policy overly broad permissions

Supply chain issues in CI tooling
