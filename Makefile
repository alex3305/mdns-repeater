# Makefile for mdns-repeater

# Set default version to Git revision or tag
VERSION ?= $(shell git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)
CFLAGS = -Wall -DVERSION="\"${VERSION}\""

ifdef DEBUG
CFLAGS += -g
else
CFLAGS += -Os
LDFLAGS := -s
endif

all: mdns-repeater
	$(info Building mdns-repeater v$(VERSION))

mdns-repeater: mdns-repeater.o

docker:
	docker buildx build . -t mdns-repeater

clean:
	rm -f .revision
	rm -f *.o
	rm -f mdns-repeater
	rm -rf tmp.*

.PHONY: all
.PHONY: clean
.PHONY: docker
