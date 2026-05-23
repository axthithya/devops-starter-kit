#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
ensure_env_file
load_env_if_present
require_env_vars APP_NAME APP_NAMESPACE MINIKUBE_PROFILE SERVICE_PORT

info "Resolving local URL for service ${APP_NAME}"

if minikube -p "${MINIKUBE_PROFILE}" status --format '{{.Host}}' 2>/dev/null | grep -qx "Running"; then
  app_url="$(minikube -p "${MINIKUBE_PROFILE}" service "${APP_NAME}" -n "${APP_NAMESPACE}" --url 2>/dev/null | head -n 1 || true)"
  if [ -n "${app_url}" ]; then
    success "Application URL: ${app_url}"
    exit 0
  fi
fi

warn "Could not resolve a Minikube service URL automatically."
info "Use port-forward instead: kubectl port-forward -n ${APP_NAMESPACE} svc/${APP_NAME} 8080:${SERVICE_PORT}"
info "Then open: http://localhost:8080"
