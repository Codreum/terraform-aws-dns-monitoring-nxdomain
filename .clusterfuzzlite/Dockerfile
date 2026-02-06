FROM gcr.io/oss-fuzz-base/base-builder-go:v1

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends sudo; \
    rm -rf /var/lib/apt/lists/*

# Copy source + build script (CFL expects $SRC/build.sh)
COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain
COPY ./.clusterfuzzlite/build.sh $SRC/build.sh
RUN chmod +x $SRC/build.sh

# Create non-root user (match GitHub runner UID commonly = 1001)
RUN set -eux; \
    useradd -m -u 1001 -s /bin/bash cflite; \
    mkdir -p /home/cflite/go; \
    chown -R cflite:cflite /home/cflite $SRC; \
    printf '%s\n' \
      'Defaults env_keep += "HOME GOPATH GOBIN PATH"' \
      'cflite ALL=(ALL) NOPASSWD:ALL' \
      > /etc/sudoers.d/cflite; \
    chmod 0440 /etc/sudoers.d/cflite; \
    touch /usr/lib/libFuzzingEngine.a; \
    chmod 666 /usr/lib/libFuzzingEngine.a; \
    real_compile="$(command -v compile)"; \
    mv "$real_compile" /usr/local/bin/compile.real; \
    cat > /usr/local/bin/compile <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Keep Go paths consistent even when running compile as root.
export HOME=/home/cflite
export GOPATH=/home/cflite/go
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:/usr/local/go/bin:$PATH

sudo -E /usr/local/bin/compile.real "$@"
rc=$?

# Avoid root-owned artifacts in the mounted OUT dir.
if [[ -n "${OUT:-}" ]]; then
  sudo chown -R cflite:cflite "$OUT" || true
fi

exit "$rc"
EOF
    chmod +x /usr/local/bin/compile

ENV HOME=/home/cflite
ENV GOPATH=/home/cflite/go
ENV GOBIN=/home/cflite/go/bin
ENV PATH=/home/cflite/go/bin:/usr/local/go/bin:$PATH

# Trivy DS002: last USER must not be root
USER cflite

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["bash","-lc","true"]
