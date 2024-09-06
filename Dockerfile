FROM ubuntu:noble-20240801 AS nim

ARG version_nim=2.0.8

RUN \
  apt-get update && \
  apt-get install -y \
    curl \
    xz-utils \
    gcc \
    openssl \
    ca-certificates \
    git && \
  rm -fr /tmp/* && \
  rm -fr /var/lib/apt/lists/*

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
  bash install.sh /usr/bin


FROM ubuntu:noble-20240801

# Nim Semver
ARG version_nim=2.0.8

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
LABEL org.opencontainers.image.description="Nim Compiler for multiple CPU architectures."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/akito13/nim"
LABEL org.opencontainers.image.documentation="https://github.com/theAkito/docker-nim?tab=readme-ov-file#run"
LABEL org.opencontainers.image.source="https://github.com/theAkito/docker-nim"
LABEL org.opencontainers.image.licenses="GPL-3.0+"

# Copy from Source directory, rather than from /usr/bin.
# https://github.com/nim-lang/Nim/issues/18979
COPY --from=nim /src/nim-${version_nim}/bin /usr/bin
COPY --from=nim /usr/lib/nim /usr/lib/nim
COPY --from=nim /etc/nim /etc/nim

RUN \
  apt-get update && \
  # Nimble Dependencies
  apt-get install -y \
    curl \
    git \
    gcc \
    openssl \
    ca-certificates && \
  # Clean up
  rm -fr /tmp/* && \
  rm -fr /var/lib/apt/lists/* && \
  # Fix Nim Installation
  ln -s /usr/lib/nim /usr/lib/nim/lib