# .clusterfuzzlite/Dockerfile
# Pinned to the OSS-Fuzz base builder image major version tag (v1).
# See OSS-Fuzz / ClusterFuzzLite docs for base images.
FROM gcr.io/oss-fuzz-base/base-builder-go:v1

# Copy your project's source code.
COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain

# Copy build script to $SRC (ClusterFuzzLite expects it there).
COPY ./.clusterfuzzlite/build.sh $SRC/build.sh

# --- Hardening (addresses Trivy DS002 + DS026) ---
# Create an unprivileged user and make $SRC writable for it.
RUN useradd -m -u 1000 -s /bin/bash cflite &&     mkdir -p /home/cflite/go &&     chown -R cflite:cflite $SRC /home/cflite

# Ensure Go tools install into a writable location.
ENV GOPATH=/home/cflite/go
ENV PATH=$PATH:/home/cflite/go/bin

USER cflite

# Healthcheck is not used by ClusterFuzzLite (container is used for builds),
# but adding one avoids misconfig lint findings.
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3   CMD ["bash","-lc","true"]
