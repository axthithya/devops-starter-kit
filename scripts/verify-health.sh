#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
ensure_env_file
load_env_if_present

failures=0

record_failure() {
  failures=$((failures + 1))
}

check_ok() {
  local label="$1"
  shift

  if "$@" >/dev/null 2>&1; then
    success "${label}"
  else
    error "${label}"
    record_failure
  fi
}

info "Checking Docker"
check_ok "Docker daemon is reachable" docker info

info "Checking Kubernetes"
check_ok "Kubernetes nodes are reachable" kubectl get nodes
check_ok "Application namespace exists: ${APP_NAMESPACE:-starter-app}" kubectl get namespace "${APP_NAMESPACE:-starter-app}"

info "Checking ArgoCD"
check_ok "ArgoCD namespace exists: ${ARGOCD_NAMESPACE:-argocd}" kubectl get namespace "${ARGOCD_NAMESPACE:-argocd}"
check_ok "ArgoCD server deployment is available" kubectl rollout status deployment/argocd-server -n "${ARGOCD_NAMESPACE:-argocd}" --timeout=60s

if kubectl get applications.argoproj.io "${ARGOCD_APP_NAME:-starter-app}" -n "${ARGOCD_NAMESPACE:-argocd}" >/dev/null 2>&1; then
  sync_status="$(kubectl get applications.argoproj.io "${ARGOCD_APP_NAME:-starter-app}" -n "${ARGOCD_NAMESPACE:-argocd}" -o jsonpath='{.status.sync.status}' 2>/dev/null || true)"
  health_status="$(kubectl get applications.argoproj.io "${ARGOCD_APP_NAME:-starter-app}" -n "${ARGOCD_NAMESPACE:-argocd}" -o jsonpath='{.status.health.status}' 2>/dev/null || true)"
  success "ArgoCD Application exists: sync=${sync_status:-Unknown}, health=${health_status:-Unknown}"
else
  error "ArgoCD Application not found: ${ARGOCD_APP_NAME:-starter-app}"
  record_failure
fi

info "Checking application workload"
if kubectl get deployment "${APP_NAME:-starter-app}" -n "${APP_NAMESPACE:-starter-app}" >/dev/null 2>&1; then
  check_ok "Application deployment is available" kubectl rollout status deployment/"${APP_NAME:-starter-app}" -n "${APP_NAMESPACE:-starter-app}" --timeout=60s
else
  error "Application deployment not found: ${APP_NAME:-starter-app}"
  record_failure
fi
check_ok "Application service exists" kubectl get service "${APP_NAME:-starter-app}" -n "${APP_NAMESPACE:-starter-app}"

info "Checking repository configuration"
if is_placeholder_value "${SONAR_ORGANIZATION:-}" || is_placeholder_value "${SONAR_PROJECT_KEY:-}"; then
  warn "SonarCloud values are still placeholders in ${ENV_FILE}; local verification can continue."
else
  success "SonarCloud project values are configured locally"
fi

if [ -f "${PROJECT_ROOT}/.github/workflows/ci.yml" ]; then
  success "GitHub Actions workflow is present"
else
  error "GitHub Actions workflow is missing"
  record_failure
fi

if is_placeholder_value "${DOCKERHUB_USERNAME:-}" || is_placeholder_value "${DOCKER_IMAGE_NAME:-}"; then
  error "DockerHub image values are incomplete in ${ENV_FILE}."
  record_failure
else
  success "DockerHub image is configured as $(resolve_image_repository):${IMAGE_TAG:-latest}"
fi

if [ "${failures}" -ne 0 ]; then
  die "Health verification found ${failures} issue(s)."
fi

success "All health checks passed"
