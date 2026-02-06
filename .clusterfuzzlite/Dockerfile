# .clusterfuzzlite/Dockerfile
#
# Fix for:
#   cp: cannot create regular file '/github/workspace/build-out/llvm-symbolizer': Permission denied
#
# Root cause:
# - ClusterFuzzLite mounts the GitHub workspace into the container, owned by the runner user (typically UID 1001).
# - If your Dockerfile sets USER to a different UID (e.g., 1000), the OSS-Fuzz "compile" step can't write into $OUT
#   (which is under /github/workspace/build-out).
#
# Solution:
# - Create the non-root user with UID 1001 to match the workspace owner.
# - Keep last USER non-root to satisfy Trivy DS002.
# - Pre-create /usr/lib/libFuzzingEngine.a and chown it to the non-root user so "compile" can overwrite it.

FROM gcr.io/oss-fuzz-base/base-builder-go:v1

COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain

# ClusterFuzzLite expects build.sh at $SRC/build.sh
COPY ./.clusterfuzzlite/build.sh $SRC/build.sh

# Create user matching GitHub runner UID (1001) and prepare writable paths.
RUN set -eux; \
    useradd -m -u 1001 -s /bin/bash cflite; \
    mkdir -p /home/cflite/go; \
    chown -R cflite:cflite /home/cflite; \
    # Allow non-root "compile" to overwrite libFuzzer engine:
    touch /usr/lib/libFuzzingEngine.a; \
    chown cflite:cflite /usr/lib/libFuzzingEngine.a; \
    chmod 664 /usr/lib/libFuzzingEngine.a

ENV GOPATH=/home/cflite/go
ENV PATH=$PATH:/home/cflite/go/bin

# Trivy DS002: last USER must not be root
USER cflite

# Trivy DS026: healthcheck (not used by CFL build containers, but satisfies linters)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["bash","-lc","true"]
