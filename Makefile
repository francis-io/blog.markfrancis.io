help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Supress printing of the make command
.SILENT:

all: serve

.PHONY: serve
serve: ## Serve on http://localhost:1313 and follow changes
	docker-compose up

.PHONY: build
build: ## Build site locally
	docker build -t hugo . && docker run --rm -v $(shell pwd):/srv/hugo hugo hugo --buildDrafts

