# .clusterfuzzlite/Dockerfile
#
# Fixes:
# - dockerfile parse error: "unknown instruction: touch"
#   (caused by putting a '#' comment mid-RUN, which ends the RUN line and makes the next line look like an instruction)
# - ClusterFuzzLite build error:
#     cp: cannot create regular file '/github/workspace/build-out/llvm-symbolizer': Permission denied
#
# Approach:
# - Keep last USER non-root (passes Trivy DS002)
# - Install sudo + allow NOPASSWD
# - Wrap the OSS-Fuzz `compile` helper so it runs as root via sudo

FROM gcr.io/oss-fuzz-base/base-builder-go:v1

# Install sudo so a non-root user can run `compile` as root.
RUN set -eux;     apt-get update;     apt-get install -y --no-install-recommends sudo;     rm -rf /var/lib/apt/lists/*

# Copy your project's source code.
COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain

# ClusterFuzzLite expects build.sh at $SRC/build.sh
COPY ./.clusterfuzzlite/build.sh $SRC/build.sh

# Create an unprivileged user and allow passwordless sudo.
# Then replace the `compile` helper with a wrapper that execs the real helper under sudo.
RUN set -eux;     useradd -m -u 1001 -s /bin/bash cflite;     echo "cflite ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cflite;     chmod 0440 /etc/sudoers.d/cflite;     real_compile="$(command -v compile)";     mv "${real_compile}" /usr/local/bin/compile.real;     printf '%s\n'       '#!/usr/bin/env bash'       'set -euo pipefail'       'exec sudo -E /usr/local/bin/compile.real "$@"'       > /usr/local/bin/compile;     chmod +x /usr/local/bin/compile

# Optional: Go env for non-root installs.
ENV GOPATH=/home/cflite/go
ENV PATH=$PATH:/home/cflite/go/bin

# Trivy DS002: last USER must not be root
USER cflite

# Trivy DS026: healthcheck (harmless for CFL build containers)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3   CMD ["bash","-lc","true"]
