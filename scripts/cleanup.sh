#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
load_env_if_present

DELETE_ARGOCD=false
DELETE_MINIKUBE=false

case "${1:-}" in
  --all)
    DELETE_ARGOCD=true
    DELETE_MINIKUBE=true
    ;;
  "")
    ;;
  *)
    die "Unknown option: $1. Use no option or --all."
    ;;
esac

APP_NAME="${APP_NAME:-starter-app}"
APP_NAMESPACE="${APP_NAMESPACE:-starter-app}"
ARGOCD_NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_APP_NAME="${ARGOCD_APP_NAME:-starter-app}"
HELM_RELEASE_NAME="${HELM_RELEASE_NAME:-${APP_NAME}}"
MINIKUBE_PROFILE="${MINIKUBE_PROFILE:-devops-starter-kit}"

info "Removing ArgoCD Application ${ARGOCD_APP_NAME}"
kubectl delete application "${ARGOCD_APP_NAME}" -n "${ARGOCD_NAMESPACE}" --ignore-not-found=true || true

info "Removing Helm release ${HELM_RELEASE_NAME}"
helm uninstall "${HELM_RELEASE_NAME}" -n "${APP_NAMESPACE}" >/dev/null 2>&1 || true

info "Removing application namespace ${APP_NAMESPACE}"
kubectl delete namespace "${APP_NAMESPACE}" --ignore-not-found=true || true

if [ "${DELETE_ARGOCD}" = "true" ]; then
  info "Removing ArgoCD namespace ${ARGOCD_NAMESPACE}"
  kubectl delete namespace "${ARGOCD_NAMESPACE}" --ignore-not-found=true || true
fi

if [ "${DELETE_MINIKUBE}" = "true" ]; then
  info "Deleting Minikube profile ${MINIKUBE_PROFILE}"
  minikube delete -p "${MINIKUBE_PROFILE}" || true
fi

success "Cleanup completed"
