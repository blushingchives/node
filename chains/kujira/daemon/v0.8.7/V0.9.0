FROM golang:1.20.8-bullseye AS build
ARG tag_version=v0.9.0

WORKDIR /build
RUN git clone \
        -c advice.detachedHead=false \
        --single-branch \
        --branch ${tag_version} \
        --depth 1 \
        https://github.com/Team-Kujira/core.git \
        kujira-core \
    && cd kujira-core \
    && make install \
    && kujirad version

RUN git clone \
        -c advice.detachedHead=false \
        --single-branch \
        --branch cosmovisor/v1.2.0 \
        --depth 1 \
        https://github.com/cosmos/cosmos-sdk.git \
        cosmos-sdk \
    && cd cosmos-sdk \
    && make cosmovisor \
    && mv cosmovisor/cosmovisor /go/bin/cosmovisor

WORKDIR /dist
RUN mkdir kujira bin lib \
    && mv $(ldd $(which kujirad) | grep libgcc_s.so.1 | awk '{print $3}') lib/ \
    && mv $(ldd $(which kujirad) | grep libwasmvm.x86_64.so | awk '{print $3}') lib/ \
    && mv $(which kujirad) bin/ \
    && mv $(which cosmovisor) bin/


FROM ubuntu:22.04

RUN apt update -y
RUN apt install wget jq curl nginx -y
COPY --from=build --chown=nonroot:nonroot /dist/kujira /kujira
COPY --from=build /dist/bin/* /usr/local/bin/
COPY --from=build /bin/stty /bin/stty
COPY --from=build /dist/lib/* /usr/lib/

# RUN mkdir /root/.kujira
# VOLUME /root/.kujira
# USER nonroot:nonroot
# WORKDIR /kujira
