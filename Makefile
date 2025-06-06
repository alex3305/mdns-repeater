# Makefile for mdns-repeater

ZIP_NAME = mdns-repeater-$(HGVERSION)
ZIP_FILES = mdns-repeater	\
			      README.md \
			      LICENSE

GIT_REVISION=$(shell git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)

CFLAGS=-Wall

ifdef DEBUG
CFLAGS+= -g
else
CFLAGS+= -Os
LDFLAGS+= -s
endif

CFLAGS+= -DGIT_REVISION="\"${GIT_REVISION}\""

.PHONY: all clean

all: mdns-repeater

mdns-repeater.o: .revision

mdns-repeater: mdns-repeater.o

.PHONY: zip
zip: TMPDIR := $(shell mktemp -d)
zip: mdns-repeater
	mkdir $(TMPDIR)/$(ZIP_NAME)
	cp $(ZIP_FILES) $(TMPDIR)/$(ZIP_NAME)
	-$(RM) $(CURDIR)/$(ZIP_NAME).zip
	cd $(TMPDIR) && zip -r $(CURDIR)/$(ZIP_NAME).zip $(ZIP_NAME)
	-$(RM) -rf $(TMPDIR)

# version checking rules
.PHONY: dummy
.revision: dummy
	@echo $(GIT_REVISION) | cmp -s $@ - || echo $(GIT_REVISION) > $@

clean:
	-$(RM) *.o
	-$(RM) .revision
	-$(RM) mdns-repeater
	-$(RM) mdns-repeater-*.zip
	-$(RM) -rf tmp.*
