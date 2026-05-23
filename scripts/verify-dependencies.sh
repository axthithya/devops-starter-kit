#!/usr/bin/env bash

set -Eeuo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"
load_env_if_present

failures=0

install_hint() {
  case "$1" in
    java) printf "Install Java %s from https://adoptium.net/temurin/releases/\n" "${JAVA_VERSION:-21}" ;;
    docker) printf "Install Docker Engine/Desktop and make sure the daemon is running.\n" ;;
    kubectl) printf "Install kubectl: https://kubernetes.io/docs/tasks/tools/\n" ;;
    helm) printf "Install Helm: https://helm.sh/docs/intro/install/\n" ;;
    minikube) printf "Install Minikube: https://minikube.sigs.k8s.io/docs/start/\n" ;;
    git) printf "Install Git: https://git-scm.com/download/linux\n" ;;
  esac
}

check_command() {
  local command_name="$1"
  local display_name="$2"

  if command_exists "${command_name}"; then
    success "${display_name} found: $(command -v "${command_name}")"
  else
    error "${display_name} is not installed or not on PATH."
    install_hint "${command_name}" >&2
    failures=$((failures + 1))
  fi
}

info "Checking required local tools"
check_command git "Git"
check_command java "Java"
check_command docker "Docker"
check_command kubectl "kubectl"
check_command helm "Helm"
check_command minikube "Minikube"

if command_exists java; then
  java_version_raw="$(java -version 2>&1 | awk -F '"' '/version/ {print $2; exit}')"
  java_major="${java_version_raw%%.*}"
  if [ "${java_major}" = "1" ]; then
    java_major="$(printf "%s" "${java_version_raw}" | cut -d. -f2)"
  fi

  if [ "${java_major:-0}" -lt "${JAVA_VERSION:-21}" ]; then
    error "Java ${JAVA_VERSION:-21}+ is required, but found ${java_version_raw}."
    failures=$((failures + 1))
  else
    success "Java version is compatible: ${java_version_raw}"
  fi
fi

if command_exists docker; then
  if docker info >/dev/null 2>&1; then
    success "Docker daemon is running"
  else
    error "Docker is installed but the daemon is not reachable."
    printf "Start Docker, then rerun: make verify\n" >&2
    failures=$((failures + 1))
  fi
fi

if uname -r | grep -qi microsoft; then
  warn "WSL2 detected. Keep Docker Desktop running with WSL integration enabled."
fi

if [ "${failures}" -ne 0 ]; then
  die "Dependency verification failed with ${failures} issue(s)."
fi

success "All required dependencies look ready"
