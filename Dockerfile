FROM rust:latest AS builder

ARG VERSION=v7.0.0-beta.1

RUN apt-get update && apt-get -y upgrade && apt-get install -y git cargo gcc g++ make cmake pkg-config llvm-dev libclang-dev clang protobuf-compiler
RUN git clone --branch=${VERSION} https://github.com/sigp/lighthouse.git

ENV FEATURES modern,gnosis
RUN cd lighthouse && make

FROM debian:buster-slim

RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
  libssl-dev \
  ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/cargo/bin/lighthouse /usr/local/bin/lighthouse

ENTRYPOINT ["lighthouse"]