# .clusterfuzzlite/Dockerfile
# ClusterFuzzLite build image for this repository.

# Use a versioned tag (not :latest) to satisfy Trivy DS001.
FROM gcr.io/oss-fuzz-base/base-builder-go@sha256:13d4331a06770446c7bcc57dd5db70616a6fd09a06c219e33fcd15fac22da7c7  # v1

# Make Go available in a stable location (sudo may reset PATH via secure_path).
# base-builder-go may install Go under /root/.go/bin.
# Ensure Go toolchain is accessible to the non-root user.
RUN set -eux; \
    if [ -x /usr/local/go/bin/go ]; then \
      echo "Go already in /usr/local/go"; \
    elif [ -x /root/.go/bin/go ]; then \
      echo "Copying Go from /root/.go -> /usr/local/go"; \
      mkdir -p /usr/local/go; \
      cp -a /root/.go/. /usr/local/go/; \
      chmod -R a+rX /usr/local/go; \
    else \
      echo "ERROR: go toolchain not found" >&2; \
      exit 1; \
    fi; \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go; \
    /usr/local/bin/go version

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends sudo procps; \
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
      'sudo -E env \
         GOPATH=/root/go \
         GOBIN=/root/go/bin \
         HOME=/root \
         PATH="/root/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
         /usr/local/bin/compile.real "$@"' \
      'if [[ -n "${OUT:-}" ]]; then sudo chown -R cflite:cflite "$OUT" || true; fi' \
      > /usr/local/bin/compile; \
    chmod +x /usr/local/bin/compile

RUN set -eux; \
    mkdir -p /home/cflite/go/gosigfuzz; \
    cp /root/go/gosigfuzz/gosigfuzz.o /home/cflite/go/gosigfuzz/; \
    chown -R cflite:cflite /home/cflite/go/gosigfuzz

USER cflite
ENV HOME=/home/cflite
ENV GOPATH=/home/cflite/go
ENV PATH=/home/cflite/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

HEALTHCHECK --interval=30s --timeout=3s CMD bash -c 'true'
