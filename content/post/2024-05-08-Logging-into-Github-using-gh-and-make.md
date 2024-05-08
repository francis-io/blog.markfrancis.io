+++
title = "Logging into Github using `gh` and `make`"
date = "2024-05-08"
+++

I wanted to manage a repository (the one that hosts the code for this website) using Terraform. The provider can use the `gh` command line application to login to Github and store some access keys. I wanted to wrap this up nicely in a `Makefile`.

This code will first check `gh` is avalable on the command line, and prompt you to install if not. It will then check that I'm logged in, and if not, will attempt to log me in. This becomes really useful as a dependant step before running Terraform.

Now I just need to figure out how to do the same with AWS to manage the custom DNS that points to this blog... :smile:

```make
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: login-gh
login-gh:  ## Login to github via gh
	@command -v gh >/dev/null 2>&1 || { echo >&2 "GitHub CLI (gh) is required but not installed."; exit 1; }
	@gh auth status > /dev/null 2>&1 || gh auth login

terraform-apply: login-gh
	terraform apply
```
