FROM akito13/alpine AS build

FROM akito13/alpine

ARG TAG="v1.3.9"
ARG BRANCH="master"
ARG BUILD_VERSION
ARG BUILD_REVISION
ARG BUILD_DATE

LABEL maintainer="Akito <the@akito.ooo>"
LABEL org.opencontainers.image.authors="Akito <the@akito.ooo>"
LABEL org.opencontainers.image.vendor="Akito"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.revision="${BUILD_REVISION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.title="Example Docker Image"
LABEL org.opencontainers.image.description="Example Docker Image for Akito/docker.tpl"
LABEL org.opencontainers.image.url="akito.ooo"
LABEL org.opencontainers.image.documentation="doc.akito.ooo"
LABEL org.opencontainers.image.source="https://github.com/theAkito/docker-alpine"
LABEL org.opencontainers.image.licenses="GPL-3.0+"

RUN apk add --update \
    alpine-sdk \
    libressl-dev

WORKDIR /root/rhash

RUN git clone https://github.com/rhash/RHash.git /root/rhash && \
    git fetch --all --tags --prune && \
    #git checkout tags/${TAG} && \
    git checkout ${BRANCH} && \
    ./configure --enable-openssl --enable-static --disable-openssl-runtime && \
    make

ENTRYPOINT [ "/bin/bash" ]
CMD [ "/entrypoint.sh" ]
