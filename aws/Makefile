.ONESHELL:
.SHELL := /usr/bin/bash
WORKSPACE="$(ENV)-$(REGION)"
BOLD=$(shell tput bold)
RESET=$(shell tput sgr0)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: validate
validate: ## run `terraform validate`
	@terraform validate

.PHONY: fmt
fmt: ## run `terraform fmt`
	@terraform fmt .

.PHONY: build
build: ## Compiles code and zips into package
	@zip -j src/slash-echo.zip src/lambda.py

.PHONY: plan
plan: build ## Show what terraform thinks it will do
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \

.PHONY: quick-plan
quick-plan: ## Show what terraform thinks it will do, but no init first
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \

.PHONY: plan-target
plan-target: ## Shows what a plan looks like for applying a specific resource
	@echo "$(YELLOW)$(BOLD)[INFO]   $(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "PLAN target: " DATA && \
		terraform plan \
			-lock=true \
			-input=true \
			-refresh=true \
			-target=$$DATA

.PHONY: plan-destroy
plan-destroy: prep ## Creates a destruction plan.
	@terraform plan \
		-input=false \
		-refresh=true \
		-destroy \

.PHONY: apply
apply: build ## Have terraform do the things. This will cost money.
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \

.PHONY: quick-apply
quick-apply: build ## Have terraform do the things, but without an init. This will cost money.
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \

.PHONY: destroy
destroy: ## Destroy the things
	@terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true \

.PHONY: destroy-target
destroy-target: ## Destroy a specific resource. Caution though, this destroys chained resources.
	@echo "$(YELLOW)$(BOLD)[INFO] Specifically destroy a piece of Terraform data.$(RESET)"; echo "Example to type for the following question: module.rds.aws_route53_record.rds-master"
	@read -p "Destroy target: " DATA && \
		terraform destroy \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file=$(VARS) \
		-target=$$DATA

