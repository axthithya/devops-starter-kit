#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

info "Creating or refreshing the ArgoCD Application"
"${PROJECT_ROOT}/scripts/bootstrap-argocd.sh"
