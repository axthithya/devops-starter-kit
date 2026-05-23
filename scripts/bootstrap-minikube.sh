#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
ensure_env_file
load_env_if_present
require_env_vars APP_NAME APP_NAMESPACE MINIKUBE_PROFILE MINIKUBE_DRIVER

info "Preparing Minikube profile ${MINIKUBE_PROFILE}"

if ! docker info >/dev/null 2>&1; then
  die "Docker is not running. Start Docker, then rerun this command."
fi

if minikube -p "${MINIKUBE_PROFILE}" status --format '{{.Host}}' 2>/dev/null | grep -qx "Running"; then
  success "Minikube profile ${MINIKUBE_PROFILE} is already running"
else
  minikube start \
    -p "${MINIKUBE_PROFILE}" \
    --driver="${MINIKUBE_DRIVER}" \
    --cpus="${MINIKUBE_CPUS:-2}" \
    --memory="${MINIKUBE_MEMORY:-4096}"
fi

minikube -p "${MINIKUBE_PROFILE}" update-context

info "Verifying Kubernetes cluster"
kubectl cluster-info
kubectl wait --for=condition=Ready nodes --all --timeout=180s

info "Ensuring application namespace ${APP_NAMESPACE}"
kubectl_apply_namespace "${APP_NAMESPACE}"

success "Minikube is ready"
