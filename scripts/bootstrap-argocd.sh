#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
ensure_env_file
load_env_if_present
require_env_vars \
  APP_NAME \
  APP_NAMESPACE \
  ARGOCD_NAMESPACE \
  ARGOCD_APP_NAME \
  ARGOCD_PROJECT \
  ARGOCD_INSTALL_MANIFEST \
  GIT_TARGET_REVISION \
  HELM_CHART_PATH \
  HELM_RELEASE_NAME \
  DOCKERHUB_USERNAME \
  DOCKER_IMAGE_NAME \
  IMAGE_TAG \
  SERVICE_TYPE \
  SERVICE_PORT \
  CONTAINER_PORT \
  REPLICA_COUNT

GIT_REPOSITORY_URL="$(resolve_git_repo_url)"
IMAGE_REPOSITORY="$(resolve_image_repository)"
APPLICATION_MANIFEST="${PROJECT_ROOT}/argocd/application.generated.yaml"

info "Installing or updating ArgoCD in namespace ${ARGOCD_NAMESPACE}"
kubectl_apply_namespace "${ARGOCD_NAMESPACE}"
kubectl apply -n "${ARGOCD_NAMESPACE}" --server-side --force-conflicts -f "${ARGOCD_INSTALL_MANIFEST}"

info "Waiting for ArgoCD workloads"
argocd_rollout_count=0

for workload_kind in deployment statefulset; do
  mapfile -t argocd_workloads < <(
    kubectl get "${workload_kind}" -n "${ARGOCD_NAMESPACE}" -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null || true
  )

  for workload_name in "${argocd_workloads[@]}"; do
    argocd_rollout_count=$((argocd_rollout_count + 1))
    kubectl rollout status "${workload_kind}/${workload_name}" -n "${ARGOCD_NAMESPACE}" --timeout=300s
  done
done

if [ "${argocd_rollout_count}" -eq 0 ]; then
  die "No ArgoCD rollout workloads found in namespace ${ARGOCD_NAMESPACE}."
fi

info "Rendering ArgoCD Application for ${ARGOCD_APP_NAME}"
mkdir -p "$(dirname "${APPLICATION_MANIFEST}")"
cat > "${APPLICATION_MANIFEST}" <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${ARGOCD_APP_NAME}
  namespace: ${ARGOCD_NAMESPACE}
spec:
  project: ${ARGOCD_PROJECT}
  source:
    repoURL: ${GIT_REPOSITORY_URL}
    targetRevision: ${GIT_TARGET_REVISION}
    path: ${HELM_CHART_PATH}
    helm:
      releaseName: ${HELM_RELEASE_NAME}
      parameters:
        - name: fullnameOverride
          value: ${APP_NAME}
        - name: namespace.create
          value: "true"
        - name: namespace.name
          value: ${APP_NAMESPACE}
        - name: replicaCount
          value: "${REPLICA_COUNT}"
        - name: image.repository
          value: ${IMAGE_REPOSITORY}
        - name: image.tag
          value: ${IMAGE_TAG}
        - name: service.type
          value: ${SERVICE_TYPE}
        - name: service.port
          value: "${SERVICE_PORT}"
        - name: service.targetPort
          value: http
        - name: container.port
          value: "${CONTAINER_PORT}"
YAML

if [ -n "${NODE_PORT:-}" ]; then
  cat >> "${APPLICATION_MANIFEST}" <<YAML
        - name: service.nodePort
          value: "${NODE_PORT}"
YAML
fi

cat >> "${APPLICATION_MANIFEST}" <<YAML
  destination:
    server: https://kubernetes.default.svc
    namespace: ${APP_NAMESPACE}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
YAML

kubectl apply -f "${APPLICATION_MANIFEST}"

success "ArgoCD Application ${ARGOCD_APP_NAME} applied"
info "Rendered manifest: ${APPLICATION_MANIFEST}"
info "ArgoCD UI access: kubectl port-forward svc/argocd-server -n ${ARGOCD_NAMESPACE} 8080:443"
info "Initial admin password: kubectl -n ${ARGOCD_NAMESPACE} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
