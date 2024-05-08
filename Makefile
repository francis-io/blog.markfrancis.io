help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# Supress printing of the make command
.SILENT:

include .env

.PHONY: apply serve

apply: _setup _login-gh _init-submodules  ## Run Terraform apply
	cd terraform && terraform apply

serve: _setup ## Serve on http://localhost:80 and follow changes
	docker-compose down; docker-compose up --build


### Supporting targets ###
.PHONY: _setup
_setup:
	asdf install > /dev/null 2>&1

.PHONY: _init-submodules
_init-submodules:
	if [ -f .gitmodules ] && [ -z "`git submodule status --recursive 2>/dev/null`" ]; then \
		echo "Initializing Git submodules..."; \
		git submodule update --init --recursive; \
	else \
		echo "Updating Git submodules..."; \
		git submodule update --recursive --remote; \
	fi

.PHONY: _login-gh
_login-gh:
	command -v gh >/dev/null 2>&1 || { echo >&2 "GitHub CLI (gh) is required but not installed."; exit 1; }
	gh auth status > /dev/null 2>&1 || gh auth login
