FROM alpine:3.18.4 AS nim

ARG version_nim=2.0.0

RUN \
  apk --no-cache add \
    musl-dev \
    curl \
    xz \
    gcc \
    openssl \
    ca-certificates \
    git && \
  rm -fr /var/cache/apk/*

WORKDIR /src

RUN \
  curl -fsSLO https://nim-lang.org/download/nim-${version_nim}.tar.xz && \
  tar -xJf nim-${version_nim}.tar.xz && \
  cd nim-${version_nim} && \
  sh build.sh && \
  bin/nim c koch && \
  chmod +x koch && \
  ./koch boot -d:release && \
  ./koch tools && \
  sh install.sh /usr/bin


FROM alpine:3.18.4

# Nim Semver
ARG version_nim=2.0.0

# Image Metadata
ARG BUILD_VERSION
ARG BUILD_REVISION
ARG BUILD_DATE

# Make Binaries installed through Nimble available
ENV PATH=/root/.nimble/bin:$PATH

LABEL maintainer="Akito <the@akito.ooo>"
LABEL org.opencontainers.image.authors="Akito <the@akito.ooo>"
LABEL org.opencontainers.image.vendor="Akito"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.revision="${BUILD_REVISION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.title="Multi-Arch Nim Compiler"
LABEL org.opencontainers.image.description="Nim Compiler for multiple CPU architectures built with musl on Alpine."
LABEL org.opencontainers.image.url="akito.ooo"
LABEL org.opencontainers.image.documentation="doc.akito.ooo"
LABEL org.opencontainers.image.source="https://github.com/theAkito/docker-nim"
LABEL org.opencontainers.image.licenses="GPL-3.0+"

# Copy from Source directory, rather than from /usr/bin.
# https://github.com/nim-lang/Nim/issues/18979
COPY --from=nim /src/nim-${version_nim}/bin /usr/bin
COPY --from=nim /usr/lib/nim /usr/lib/nim
COPY --from=nim /etc/nim /etc/nim

RUN \
  apk --no-cache add \
    # Nim Dependencies
    musl-dev \
    gcc \
    # Nimble Dependencies
    curl \
    openssl \
    ca-certificates \
    git && \
  # Clean up
  rm -fr /var/cache/apk/* && \
  # Fix Nim Installation
  ln -s /usr/lib/nim /usr/lib/nim/lib