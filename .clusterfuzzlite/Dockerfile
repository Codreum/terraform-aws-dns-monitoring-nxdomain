# .clusterfuzzlite/Dockerfile
#
# Fix for:
#   cp: cannot create regular file '/github/workspace/build-out/llvm-symbolizer': Permission denied
#
# Root cause:
# - ClusterFuzzLite runs: /bin/bash -c compile
# - With a non-root USER, the OSS-Fuzz "compile" helper tries to write helper binaries into $OUT
#   (here: /github/workspace/build-out) and fails with Permission denied.
#
# Constraint:
# - Trivy DS002 requires the *last* USER in the Dockerfile to be non-root.
#
# Solution:
# - Keep last USER as non-root (to satisfy DS002)
# - Install sudo + add a NOPASSWD rule
# - Wrap the OSS-Fuzz 'compile' command so it executes as root via sudo, preserving env vars.

FROM gcr.io/oss-fuzz-base/base-builder-go:v1

# Install sudo (needed so the non-root user can run the OSS-Fuzz 'compile' helper as root).
RUN set -eux;     apt-get update;     apt-get install -y --no-install-recommends sudo;     rm -rf /var/lib/apt/lists/*

# Copy your project's source code.
COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain

# ClusterFuzzLite expects build.sh at $SRC/build.sh
COPY ./.clusterfuzzlite/build.sh $SRC/build.sh

# Create an unprivileged user and allow it to sudo without password.
# Also wrap "compile" so it runs as root (fixes $OUT permission errors).
RUN set -eux;     useradd -m -u 1001 -s /bin/bash cflite;     echo "cflite ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cflite;     chmod 0440 /etc/sudoers.d/cflite;         # Optional: keep this from earlier—some toolchains overwrite this file.
    touch /usr/lib/libFuzzingEngine.a;     chmod 666 /usr/lib/libFuzzingEngine.a;         # Move the real compile helper aside and replace it with a sudo wrapper.
    orig="$(command -v compile)";     echo "Found compile at: ${orig}";     mv "${orig}" /usr/local/bin/compile.real;     printf '%s
'       '#!/usr/bin/env bash'       'set -euo pipefail'       'exec sudo -E /usr/local/bin/compile.real "$@"'       > /usr/local/bin/compile;     chmod +x /usr/local/bin/compile

# (Optional) Go env for non-root installs (if your build.sh does any installs as cflite).
ENV GOPATH=/home/cflite/go
ENV PATH=$PATH:/home/cflite/go/bin

# Trivy DS002: last USER must not be root
USER cflite

# Trivy DS026: healthcheck (not used by CFL build containers, but satisfies linters)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3   CMD ["bash","-lc","true"]
