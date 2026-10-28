# Mirrors upstream's own Dockerfile at the pinned tag:
# https://github.com/sigp/lighthouse/blob/v8.3.2/Dockerfile
# Lighthouse v8.3.x requires Rust >= 1.91.0 (rust-version in lighthouse/Cargo.toml).
FROM rust:1.91.0-bookworm AS builder

# renovate: datasource=github-releases depName=sigp/lighthouse
ARG VERSION=v8.3.2
# Extra cargo features, see [features] in lighthouse/Cargo.toml. Upstream's release builds use
# `portable`; `modern` no longer builds (blst refuses `portable` together with `force-adx`).
# `gnosis` adds the Gnosis networks.
ARG FEATURES=portable,gnosis
ARG PROFILE=release

RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
    cmake \
    libclang-dev \
    clang \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${VERSION}" https://github.com/sigp/lighthouse.git /lighthouse

WORKDIR /lighthouse
ENV FEATURES=${FEATURES} \
    PROFILE=${PROFILE} \
    CARGO_NET_GIT_FETCH_WITH_CLI=true
# `make` runs `cargo install --locked`, which installs into /usr/local/cargo/bin.
RUN make

FROM ubuntu:24.04

RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
    libssl-dev \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/lighthouse /usr/local/bin/lighthouse

ENTRYPOINT ["lighthouse"]
