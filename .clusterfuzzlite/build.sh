#!/usr/bin/env bash
set -euo pipefail

cd "$SRC/terraform-aws-dns-monitoring-nxdomain"

# Needed by compile_native_go_fuzzer for native Go fuzzers.
go install github.com/AdamKorcz/go-118-fuzz-build@latest
go get github.com/AdamKorcz/go-118-fuzz-build/testing

go mod download

# Build the native Go fuzz target into a libFuzzer-style binary.
# Args: <package> <fuzzFuncName> <outBinaryName> [optional build tag]
compile_native_go_fuzzer \
  github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/fuzz \
  FuzzHCLParse \
  fuzz_hclparse
