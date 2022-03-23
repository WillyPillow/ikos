#------------------------------#
# BUILD STAGE
#------------------------------#

FROM docker.io/ubuntu:20.04 AS base

ARG njobs=2
ARG build_type=Release

WORKDIR /root/ikos

# Upgrade
RUN apt-get update -y \
 && apt-get install -y wget gnupg \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata \
 && apt-get install -y gcc g++ cmake libgmp-dev libboost-dev \
        libboost-filesystem-dev libboost-thread-dev libboost-test-dev python3 python3-pygments python3-distutils \
        libsqlite3-dev libtbb-dev libz-dev libedit-dev llvm-9 llvm-9-dev llvm-9-tools clang-9 \
        git doxygen libmpfr-dev libppl-dev libapron-dev \
 && git clone --single-branch https://github.com/NASA-SW-VnV/ikos.git . \
 && rm -rf /root/ikos/build && mkdir /root/ikos/build \
 && apt-get clean

WORKDIR /root/ikos/build
ENV MAKEFLAGS "-j$njobs"

RUN cmake \
        -DCMAKE_INSTALL_PREFIX="/opt/ikos" \
        -DCMAKE_BUILD_TYPE="$build_type" \
        -DLLVM_CONFIG_EXECUTABLE="/usr/lib/llvm-9/bin/llvm-config" \
        .. \
 && make \
 && make install

#------------------------------#
# FINAL STAGE
#------------------------------#

FROM ubuntu:20.04

COPY --from=base /opt/ikos /opt/ikos

RUN apt-get update -y && apt-get install -y \
    python \
    clang-9 \
    libboost-filesystem-dev \
    libgmp-dev \
 && rm -rf /var/lib/apt/lists/*

ENV PATH "/opt/ikos/bin:$PATH"

WORKDIR /src
LABEL maintainer="begarco"
