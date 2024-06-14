# syntax=docker/dockerfile:1.8
FROM bitnami/minideb:bullseye AS builder

ARG PACKAGE=dumb-init
ARG TARGET_DIR=common
# renovate: datasource=github-releases depName=Yelp/dumb-init extractVersion=^v(?<version>\d+\.\d+.\d+)
ARG VERSION=1.2.5
ARG REF=v${VERSION}

RUN mkdir -p /opt/bitnami
RUN <<EOT /bin/bash
    set -ex

    apt update
    apt install -y --no-install-recommends build-essential make git ca-certificates

    rm -rf ${PACKAGE} || true
    mkdir -p ${PACKAGE}
    git clone -b "${REF}" https://github.com/Yelp/dumb-init.git ${PACKAGE}

    pushd ${PACKAGE}
    make build

    mkdir -p /opt/bitnami/${TARGET_DIR}/bin
    mkdir -p /opt/bitnami/${TARGET_DIR}/licenses/
    cp -f ${PACKAGE} /opt/bitnami/${TARGET_DIR}/bin/${PACKAGE}
    cp -f LICENSE /opt/bitnami/${TARGET_DIR}/licenses/${PACKAGE}-${VERSION}.txt
    popd

    rm -rf ${PACKAGE}
EOT

FROM bitnami/minideb:bullseye as stage-0

COPY --link --from=builder /opt/bitnami /opt/bitnami
