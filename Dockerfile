FROM alpine:3.22.0 AS builder

COPY * /tmp/

RUN apk add --no-cache git gcc musl-dev make && \
    git config --global --add safe.directory /tmp && \
    cd /tmp/ && \
    make && \
    chmod a+rx /tmp/mdns-repeater

FROM alpine:3.22.0

COPY --from=builder /tmp/mdns-repeater /usr/local/bin/

EXPOSE 5353

ENTRYPOINT ["/usr/local/bin/mdns-repeater"]
CMD ["-h"]
