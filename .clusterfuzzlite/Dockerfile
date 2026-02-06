# .clusterfuzzlite/Dockerfile
# ClusterFuzzLite build image for this repository.

# Use a versioned tag (not :latest) to satisfy Trivy DS001.
FROM gcr.io/oss-fuzz-base/base-builder-go:v1

# Make Go available in a stable location (sudo may reset PATH via secure_path).
# base-builder-go may install Go under /root/.go/bin.
RUN set -eux; \
    if command -v go >/dev/null 2>&1; then \
      go_bin="$(command -v go)"; \
    elif [ -x /root/.go/bin/go ]; then \
      go_bin="/root/.go/bin/go"; \
    elif [ -x /usr/local/go/bin/go ]; then \
      go_bin="/usr/local/go/bin/go"; \
    else \
      echo "ERROR: go binary not found in base image" >&2; \
      exit 1; \
    fi; \
    ln -sf "$go_bin" /usr/local/bin/go; \
    /usr/local/bin/go version

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends sudo; \
    rm -rf /var/lib/apt/lists/*

COPY . /src/terraform-aws-dns-monitoring-nxdomain
WORKDIR /src/terraform-aws-dns-monitoring-nxdomain

COPY ./.clusterfuzzlite/build.sh /src/build.sh
RUN chmod +x /src/build.sh

RUN set -eux; \
    useradd -m -u 1001 -s /bin/bash cflite; \
    mkdir -p /home/cflite/go; \
    chown -R cflite:cflite /home/cflite; \
    echo "cflite ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/cflite; \
    chmod 0440 /etc/sudoers.d/cflite; \
    real_compile="$(command -v compile)"; \
    mv "$real_compile" /usr/local/bin/compile.real; \
    printf '%s\n' \
      '#!/usr/bin/env bash' \
      'set -euo pipefail' \
      'sudo -E /usr/local/bin/compile.real "$@"' \
      'if [[ -n "${OUT:-}" ]]; then sudo chown -R cflite:cflite "$OUT" || true; fi' \
      > /usr/local/bin/compile; \
    chmod +x /usr/local/bin/compile

USER cflite
ENV HOME=/home/cflite
ENV GOPATH=/home/cflite/go
ENV PATH=/home/cflite/go/bin:/usr/local/bin:/usr/bin:/bin

HEALTHCHECK --interval=30s --timeout=3s CMD bash -c 'true'
