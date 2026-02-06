#!/usr/bin/env bash
set -euo pipefail

cd "$SRC/terraform-aws-dns-monitoring-nxdomain"

# IMPORTANT:
# The base-builder-go image is configured around HOME=/root and GOPATH=/root/go.
# When we run under a non-root USER, those values can change (HOME=/home/...), which breaks
# compile_native_go_fuzzer because it looks for gosigfuzz.o under $GOPATH/gosigfuzz/.
#
# We force the same Go env the base image expects.
export HOME=/root
export GOPATH=/root/go
export PATH="/root/.go/bin:$GOPATH/bin:$PATH"

# Ensure the helper binary is installed somewhere on PATH.
# (Keeping it in $GOPATH/bin is the most compatible with OSS-Fuzz helper scripts.)
export GOBIN="$GOPATH/bin"

# Needed by compile_native_go_fuzzer for native Go fuzzers.
go install github.com/AdamKorcz/go-118-fuzz-build@latest
go get github.com/AdamKorcz/go-118-fuzz-build/testing@latest

go mod download

# Build the native Go fuzz target into a libFuzzer-style binary.
# Args: <package> <fuzzFuncName> <outBinaryName> [optional build tag]
compile_native_go_fuzzer \
  github.com/Codreum/terraform-aws-dns-monitoring-nxdomain/fuzz \
  FuzzHCLParse \
  fuzz_hclparse
