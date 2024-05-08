help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Supress printing of the make command
.SILENT:

include .env

.PHONY: setup
setup:
	@asdf install

.PHONY: login-gh
login-gh:  ## Login to github via gh
	@command -v gh >/dev/null 2>&1 || { echo >&2 "GitHub CLI (gh) is required but not installed."; exit 1; }
	@gh auth status > /dev/null 2>&1 || gh auth login

# login-aws:
# 	@if [ -z "$(AWS_ACCESS_KEY_ID)" ]; then \
#         read -p "Enter your AWS access key ID: " AWS_ACCESS_KEY_ID; \
#         export AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID; \
# 	fi
# 	@if [ -z "$(AWS_SECRET_ACCESS_KEY)" ]; then \
#         read -p "Enter your AWS secret access key: " AWS_SECRET_ACCESS_KEY; \
#         AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY; \
#     fi

terraform-apply: login-gh
	cd terraform && terraform apply

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

