SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

.PHONY: help setup verify deploy minikube argocd cleanup cleanup-all open-app test docker-build helm-template

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*##"; printf "\nDevOps Starter Kit commands:\n\n"} /^[a-zA-Z0-9_-]+:.*##/ {printf "  %-16s %s\n", $$1, $$2} END {printf "\n"}' $(MAKEFILE_LIST)

setup: ## Verify dependencies, start Minikube, install ArgoCD, and apply the GitOps app
	@./scripts/setup.sh

verify: ## Check local tools, cluster health, ArgoCD, and app status
	@./scripts/verify-health.sh

deploy: ## Create or refresh the ArgoCD Application from .env
	@./scripts/deploy.sh

minikube: ## Start or verify the Minikube cluster
	@./scripts/bootstrap-minikube.sh

argocd: ## Install or verify ArgoCD and apply the Application
	@./scripts/bootstrap-argocd.sh

cleanup: ## Remove the app and ArgoCD Application, keeping Minikube available
	@./scripts/cleanup.sh

cleanup-all: ## Remove the app, ArgoCD, and the Minikube profile
	@./scripts/cleanup.sh --all

open-app: ## Print the local Minikube URL for the deployed app
	@./scripts/open-app.sh

test: ## Run the Spring Boot test/build verification
	@cd app && ./mvnw --batch-mode --no-transfer-progress clean verify

docker-build: ## Build the app image locally using .env values
	@source ./scripts/lib/common.sh && ensure_env_file && load_env_if_present && docker build -t "$$(resolve_image_repository):$${IMAGE_TAG:-latest}" ./app

helm-template: ## Render the Helm chart locally using .env values
	@source ./scripts/lib/common.sh && \
	ensure_env_file && \
	load_env_if_present && \
	IMAGE_REPOSITORY="$$(resolve_image_repository)" && \
	helm template "$${HELM_RELEASE_NAME:-starter-app}" helm/starter-app \
		--namespace "$${APP_NAMESPACE:-starter-app}" \
		--set fullnameOverride="$${APP_NAME:-starter-app}" \
		--set namespace.name="$${APP_NAMESPACE:-starter-app}" \
		--set replicaCount="$${REPLICA_COUNT:-1}" \
		--set image.repository="$${IMAGE_REPOSITORY}" \
		--set image.tag="$${IMAGE_TAG:-latest}" \
		--set service.type="$${SERVICE_TYPE:-NodePort}" \
		--set service.port="$${SERVICE_PORT:-80}" \
		--set service.targetPort=http \
		--set container.port="$${CONTAINER_PORT:-8080}" \
		$${NODE_PORT:+--set service.nodePort=$${NODE_PORT}}
