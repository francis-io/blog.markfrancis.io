help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Supress printing of the make command
.SILENT:

include .env

.PHONY: update
update:
	# git submodule add https://github.com/luizdepra/hugo-coder.git themes/hugo-coder
	# git submodule update --init --recursive
	git submodule update --recursive

.PHONY: serve
serve: update ## Serve on http://localhost:8080 and follow changes
	docker-compose up --build

.PHONY: down
down:  ## Stop and destroy local containers
	docker-compose down
	#docker-compose rm -fsv

.PHONY: build
build: update ## Build site locally
	docker build \
		--build-arg ALPINE_VERSION=${ALPINE_VERSION} \
		--build-arg HUGO_VERSION=${HUGO_VERSION} \
		-t hugo . && \
		docker run --rm -v $(shell pwd):/srv/hugo hugo hugo

