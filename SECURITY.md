\# Security Policy



\## Reporting a vulnerabilty



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



\## Disclosure \& response timelines



We follow **coordinated vulnerability disclosure**.

* **Acknowledgement:** within **2 business days**
* **Initial triage:** within **5 business days** (confirm impact, severity, and affected versions)
* **Remediation target:** for confirmed vulnerabilities, we aim to provide a fix or mitigation within **90 days**, or share a concrete status update if more time is required
* **Ongoing updates:** we will provide progress updates at least every **14 days** while a fix is in progress
* **Public disclosure:** we prefer disclosure **after a fix is available** (or mitigations are documented), coordinated with the reporter

If you believe active exploitation is occurring, please note that in your report so we can prioritize.



\## Supported Version



Security fixes are provided for:

* The latest released version
* Recent minor versions where feasible



\## Scope



This repo contains Terraform infrastructure code (no runtime service). Security issues may include:

* Credential exposure risk
* Insecure defaults
* IAM policy overly broad permissions

Supply chain issues in CI tooling



\## Cryptography



This project is a Terraform module and does not implement cryptographic algorithms or protocols.

Any encryption in transit (e.g., HTTPS/TLS) is provided by AWS services and/or GitHub, not by this code.



\## Secure development practices



This project is a Terraform module that provisions AWS monitoring resources (CloudWatch alarms/dashboards, Contributor Insights, SNS notifications). The maintainers follow secure-by-default design and review practices appropriate for Infrastructure-as-Code.



\### Secure design approach

\- \*\*Least privilege:\*\* avoid overly broad permissions and prefer narrow scopes/conditions in policies.

\- \*\*No secret handling:\*\* the module should not require or store secrets; do not add secrets to Terraform variables, state, issues, or PRs.

\- \*\*Minimize data exposure:\*\* DNS logs remain in the user’s AWS account; resources created by this module should not expose logs publicly.

\- \*\*Review \& automation:\*\* changes are reviewed via pull requests and validated by CI checks (formatting, validation, policy checks, and security scanning).



\### Common security risks for IaC modules and mitigations

\- \*\*Overly-permissive IAM or resource policies\*\* (e.g., wide `\*` actions/resources)  

&nbsp; \*Mitigation:\* keep permissions minimal; add/adjust policy checks; review diffs carefully.

\- \*\*Unintended access to logs/metrics\*\* (e.g., log groups readable by broad principals)  

&nbsp; \*Mitigation:\* restrict access to operational roles; avoid granting public or overly broad access.

\- \*\*Misconfiguration drift / breaking changes\*\*  

&nbsp; \*Mitigation:\* keep examples updated; use CI validation/plan checks; document behavior changes clearly.

\- \*\*Supply-chain / CI workflow risk\*\* (e.g., unpinned actions, dependency drift)  

&nbsp; \*Mitigation:\* pin/track dependencies and keep security scanners enabled (IaC scanning, linting, and workflow analysis).



If you believe a change could impact security (permissions, data exposure, authentication/authorization boundaries), call it out explicitly in the PR description for additional review.



