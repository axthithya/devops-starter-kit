#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${PROJECT_ROOT}/.env}"

if [ -t 1 ]; then
  BOLD="$(tput bold 2>/dev/null || true)"
  DIM="$(tput dim 2>/dev/null || true)"
  RED="$(tput setaf 1 2>/dev/null || true)"
  GREEN="$(tput setaf 2 2>/dev/null || true)"
  YELLOW="$(tput setaf 3 2>/dev/null || true)"
  BLUE="$(tput setaf 4 2>/dev/null || true)"
  RESET="$(tput sgr0 2>/dev/null || true)"
else
  BOLD=""
  DIM=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  RESET=""
fi

info() {
  printf "%s==>%s %s\n" "${BLUE}" "${RESET}" "$*"
}

success() {
  printf "%sOK%s  %s\n" "${GREEN}" "${RESET}" "$*"
}

warn() {
  printf "%sWARN%s %s\n" "${YELLOW}" "${RESET}" "$*" >&2
}

error() {
  printf "%sERROR%s %s\n" "${RED}" "${RESET}" "$*" >&2
}

die() {
  error "$*"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

ensure_env_file() {
  if [ ! -f "${ENV_FILE}" ]; then
    cp "${PROJECT_ROOT}/.env.example" "${ENV_FILE}"
    warn "Created ${ENV_FILE} from .env.example."
    die "Edit ${ENV_FILE} with your GitHub, DockerHub, and SonarCloud values, then rerun the command."
  fi
}

load_env_if_present() {
  if [ -f "${ENV_FILE}" ]; then
    set -a
    # shellcheck disable=SC1090
    . "${ENV_FILE}"
    set +a
  fi
}

is_placeholder_value() {
  local value="${1:-}"
  local normalized="${value,,}"

  case "${normalized}" in
    ""|your-*|your_*|*your-github-username*|*your_repository*|*your-repository*|*your-dockerhub-username*|*your-sonarcloud-*|*replace_me*|*changeme*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

require_env_vars() {
  local missing=0
  local key
  local value

  for key in "$@"; do
    value="${!key:-}"
    if is_placeholder_value "${value}"; then
      error "Set ${key} in ${ENV_FILE}."
      missing=1
    fi
  done

  if [ "${missing}" -ne 0 ]; then
    die "Configuration is incomplete. Update ${ENV_FILE} and run the command again."
  fi
}

resolve_image_repository() {
  if [ -n "${IMAGE_REPOSITORY:-}" ]; then
    printf "%s" "${IMAGE_REPOSITORY}"
    return 0
  fi

  if is_placeholder_value "${DOCKERHUB_USERNAME:-}" || is_placeholder_value "${DOCKER_IMAGE_NAME:-}"; then
    die "Set DOCKERHUB_USERNAME and DOCKER_IMAGE_NAME in ${ENV_FILE}."
  fi

  printf "%s/%s" "${DOCKERHUB_USERNAME}" "${DOCKER_IMAGE_NAME}"
}

kubectl_apply_namespace() {
  local namespace="$1"
  kubectl create namespace "${namespace}" --dry-run=client -o yaml | kubectl apply -f -
}

repo_relative() {
  local path="$1"
  printf "%s/%s" "${PROJECT_ROOT}" "${path}"
}
