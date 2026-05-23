#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
ensure_env_file
load_env_if_present

require_env_vars \
  APP_NAME \
  APP_NAMESPACE \
  GIT_TARGET_REVISION \
  HELM_CHART_PATH \
  HELM_RELEASE_NAME \
  DOCKERHUB_USERNAME \
  DOCKER_IMAGE_NAME \
  IMAGE_TAG \
  MINIKUBE_PROFILE \
  MINIKUBE_DRIVER \
  ARGOCD_NAMESPACE \
  ARGOCD_APP_NAME \
  ARGOCD_PROJECT \
  ARGOCD_INSTALL_MANIFEST

if is_placeholder_value "${SONAR_ORGANIZATION:-}" || is_placeholder_value "${SONAR_PROJECT_KEY:-}"; then
  warn "SonarCloud values are still placeholders. Local setup can continue, but CI will require real SonarCloud values."
fi

resolve_git_repo_url >/dev/null
resolve_image_repository >/dev/null

info "Starting DevOps Starter Kit setup"
"${PROJECT_ROOT}/scripts/verify-dependencies.sh"
"${PROJECT_ROOT}/scripts/bootstrap-minikube.sh"
"${PROJECT_ROOT}/scripts/bootstrap-argocd.sh"

success "Setup completed"
info "Next: run make verify, then make open-app."
info "When you are ready for your own CI/CD, add the GitHub secrets and variables listed in README.md."
