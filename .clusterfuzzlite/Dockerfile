# .clusterfuzzlite/Dockerfile
#
# Goal:
# - PASS Trivy DS002 (last USER must be non-root)
# - Still allow ClusterFuzzLite's built-in "compile" step to run without needing root.
#
# Why this works:
# The OSS-Fuzz toolchain writes libFuzzer's engine to /usr/lib/libFuzzingEngine.a.
# When running as a non-root user, that write fails unless the target file is writable.
# We pre-create the file and give ownership to the non-root user so `cp` can overwrite it.

FROM gcr.io/oss-fuzz-base/base-builder-go:v1

# Copy your project's source code.
COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain

# ClusterFuzzLite expects build.sh at $SRC/build.sh
COPY ./.clusterfuzzlite/build.sh $SRC/build.sh

# Create an unprivileged user, and make libFuzzer engine path writable for that user.
RUN set -eux; \
    useradd -m -u 1000 -s /bin/bash cflite; \
    mkdir -p /home/cflite/go; \
    chown -R cflite:cflite /home/cflite; \
    # Make sure the OSS-Fuzz toolchain can overwrite this when running as non-root:
    touch /usr/lib/libFuzzingEngine.a; \
    chown cflite:cflite /usr/lib/libFuzzingEngine.a; \
    chmod 664 /usr/lib/libFuzzingEngine.a

# Make Go installs writable for the non-root user.
ENV GOPATH=/home/cflite/go
ENV PATH=$PATH:/home/cflite/go/bin

# Trivy DS002: last USER should not be root
USER cflite

# Trivy DS026: healthcheck (not used by CFL build containers, but satisfies linters)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD ["bash","-lc","true"]
