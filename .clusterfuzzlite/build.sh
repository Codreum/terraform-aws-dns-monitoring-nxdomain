#!/usr/bin/env bash
set -euo pipefail

cd "$SRC/terraform-aws-dns-monitoring-nxdomain"

# Ensure Go + installed tools are always found.
export HOME=/home/cflite
export GOPATH=/home/cflite/go
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:/usr/local/go/bin:$PATH"

go install github.com/AdamKorcz/go-118-fuzz-build@latest
go get github.com/AdamKorcz/go-118-fuzz-build/testing@latest

go mod download

compile_native_go_fuzzer \
  github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/fuzz \
  FuzzHCLParse \
  fuzz_hclparse
