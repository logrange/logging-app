export VERSION ?= $(shell git describe --abbrev=0 --tags)
REPOSITORY := gravitational.io
NAME := logging-app
OPS_URL ?= https://opscenter.localhost.localdomain:33009
OUT ?= $(NAME).tar.gz
GRAVITY ?= gravity
UPDATE_IMAGE_OPTS := \
	--set-image=log-adapter:$(VERSION) \
	--set-image=log-hook:$(VERSION)
UPDATE_METADATA_OPTS := --repository=$(REPOSITORY) --name=$(NAME) --version=$(VERSION)

.PHONY: package
package:
	$(MAKE) -C images all

.PHONY: adapter
collector:
	$(MAKE) -C images adapter

.PHONY: hook
hook:
	$(MAKE) -C images hook

.PHONY: deploy
deploy:
	$(MAKE) -C images deploy

.PHONY: import
import: package
	-$(GRAVITY) app delete \
		--ops-url=$(OPS_URL) \
		$(REPOSITORY)/$(NAME):$(VERSION) \
		--force --insecure
	$(GRAVITY) app import --insecure --vendor \
		--ops-url=$(OPS_URL) \
		$(UPDATE_IMAGE_OPTS) \
		$(UPDATE_METADATA_OPTS) \
		--include=resources --include=registry .

.PHONY: tarball
tarball: import
	$(GRAVITY) package export \
		--ops-url=$(OPS_URL) \
		$(REPOSITORY)/$(NAME):$(VERSION) \
		$(NAME)-$(VERSION).tar.gz

.PHONY: clean
clean:
	$(MAKE) -C images clean
