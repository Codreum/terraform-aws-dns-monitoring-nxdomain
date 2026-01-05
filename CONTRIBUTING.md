# Contributing

Thanks for your interest in contributing to **terraform-aws-dns-monitoring-free**.

## Scope & support
- **Free module** support is via **GitHub Issues**.
- For **Pro/Paid** offerings, please refer to Codreum support/SLA channels.

## Development prerequisites
- Terraform: recommended `>= 1.7.0` (or follow repo / example constraints)
- AWS credentials if you plan to run real plans/applies (not required for fmt/validate)

## Local checks (required before PR)
From repo root:

### 1) Format
```bash
terraform fmt -recursive
```

### 2) Validate module
```bash
terraform -chdir=modules init -backend=false
terraform -chdir=modules validate
```

### 3) Validate examples
Run these for each example folder:
```bash
terraform -chdir=examples/both-zone-vpc init -backend=false
terraform -chdir=examples/both-zone-vpc validate

terraform -chdir=examples/zone-only init -backend=false
terraform -chdir=examples/zone-only validate

terraform -chdir=examples/vpc-only init -backend=false
terraform -chdir=examples/vpc-only validate
```

> Note: Examples may reference a module source/tag. CI validates syntax and structure; apply requires real AWS resources/logs.

## Pull requests
1. Create a branch from `main`
2. Make your change with focused commits
3. Ensure CI passes
4. Open a PR with a clear title and description:
   - What changed
   - Why it changed
   - How it was tested

## Release / versioning
- Use semver tags: `v0.1.0`, `v0.1.1`, etc.
- Don’t move existing tags to new commits (publish a new version instead).

## Code style
- Prefer readable Terraform: meaningful names, comments where needed
- Keep dashboards stable (avoid noisy diffs)
- Avoid breaking changes in minor versions when possible

## License
By submitting a PR, you agree your contribution may be redistributed under this repository’s license.
