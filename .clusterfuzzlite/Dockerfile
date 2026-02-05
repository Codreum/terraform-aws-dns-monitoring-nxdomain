FROM gcr.io/oss-fuzz-base/base-builder-go

COPY . $SRC/terraform-aws-dns-monitoring-nxdomain
WORKDIR $SRC/terraform-aws-dns-monitoring-nxdomain

COPY ./.clusterfuzzlite/build.sh $SRC/build.sh
