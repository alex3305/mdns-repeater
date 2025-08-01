# mDNS Repeater Docker image

FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1 AS builder

# Optional version, otherwise git tag or revision will be used.
ARG VERSION

# renovate: datasource=repology depName=alpine_3_22/git versioning=loose
ARG GIT_VERSION=2.49.1-r0
# renovate: datasource=repology depName=alpine_3_22/gcc versioning=loose
ARG GCC_VERSION=14.2.0-r6
# renovate: datasource=repology depName=alpine_3_22/musl-dev versioning=loose
ARG MUSL_DEV_VERSION=1.2.5-r10
# renovate: datasource=repology depName=alpine_3_22/make versioning=loose
ARG MAKE_VERSION=4.4.1-r3

COPY ./* /root/

RUN apk add --no-cache git="${GIT_VERSION}" \
                       gcc="${GCC_VERSION}" \
                       musl-dev="${MUSL_DEV_VERSION}" \
                       make="${MAKE_VERSION}" \
    && \
    git config --global --add safe.directory '*' && \
    cd /root/ \
    && \
    make

FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

COPY --from=builder --chmod=0555 /root/mdns-repeater /usr/local/bin/

EXPOSE 5353

ENTRYPOINT ["/usr/local/bin/mdns-repeater"]
CMD ["-h"]

LABEL \
    maintainer="Alex van den Hoogen <alex@alxx.nl>" \
    org.opencontainers.image.title="mDNS Repeater" \
    org.opencontainers.image.description="Containerized mDNS Repeater"
