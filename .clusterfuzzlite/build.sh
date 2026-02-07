#!/usr/bin/env bash
set -euo pipefail

cd "$SRC/terraform-aws-dns-monitoring-nxdomain"

# Ensure Go + installed tools are always found.
export PATH="${GOBIN:-$GOPATH/bin}:/usr/local/go/bin:$PATH"

go install github.com/AdamKorcz/go-118-fuzz-build@v0.0.0-20250520111509-a70c2aa677fa
go get github.com/AdamKorcz/go-118-fuzz-build/testing@v0.0.0-20250520111509-a70c2aa677fa

go mod download

compile_native_go_fuzzer \
  github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/fuzz \
  FuzzHCLParse \
  fuzz_hclparse
