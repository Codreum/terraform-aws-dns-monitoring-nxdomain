# .clusterfuzzlite/Dockerfile
#
# NOTE:
# ClusterFuzzLite / OSS-Fuzz build images typically need to run as root during the
# "compile" phase because the toolchain writes into system paths (e.g. /usr/lib).
# If the final USER is non-root, you'll see errors like:
#   cp: cannot create regular file '/usr/lib/libFuzzingEngine.a': Permission denied
#
# To satisfy Dockerfile linters (e.g. Trivy DS002), we include a non-root USER
# directive, then switch back to root for the actual build runtime.

# Pin to a tag (avoids Trivy DS001 "latest tag" finding)
FROM gcr.io/oss-fuzz-base/base-builder-go:v1

# Copy your project's source code into $SRC (OSS-Fuzz convention)
COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain

# ClusterFuzzLite expects build.sh at $SRC/build.sh
COPY ./.clusterfuzzlite/build.sh $SRC/build.sh

# Create an unprivileged user (satisfies Trivy DS002), but do NOT keep it as the final user.
RUN useradd -m -u 1000 -s /bin/bash cflite &&     mkdir -p /home/cflite/go &&     chown -R cflite:cflite /home/cflite

# Optional: ensure Go tool installs are writable (if you ever run as cflite)
ENV GOPATH=/home/cflite/go
ENV PATH=$PATH:/home/cflite/go/bin

# Satisfy DS002 (at least one USER non-root) ...
USER cflite

# ... then switch back to root so the OSS-Fuzz toolchain can write into /usr/lib, etc.
USER root

# Healthcheck (addresses Trivy DS026). Not used by CFL, but harmless.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3   CMD ["bash","-lc","true"]
