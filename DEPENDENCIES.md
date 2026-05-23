# Dependency Installation Guide

This guide helps you prepare an Ubuntu machine for the DevOps Starter Kit.

Install these tools first, then return to the README and run the local demo.

The commands below are written for Ubuntu on 64-bit Intel/AMD machines. If you use WSL2, keep Docker Desktop running with WSL integration enabled.

## Quick Check

If you already have the tools installed, you can check them with:

```bash
git --version
java -version
docker --version
docker info
kubectl version --client
helm version
minikube version
```

After cloning this repository, you can also run:

```bash
./scripts/verify-dependencies.sh
```

## Git

Git is used to clone this repository and push your own changes to GitHub.

Install:

```bash
sudo apt update
sudo apt install -y git
```

Verify:

```bash
git --version
```

## Java 21

Java 21 is used to build and test the Spring Boot application.

Install Eclipse Temurin 21:

```bash
sudo apt update
sudo apt install -y wget apt-transport-https gpg
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install -y temurin-21-jdk
```

Verify:

```bash
java -version
```

The version output should mention Java 21.

## Docker

Docker is used to build and run containers. Minikube also uses Docker as the local Kubernetes driver in this project.

Install Docker Engine:

```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Start Docker:

```bash
sudo systemctl enable --now docker
```

Allow your current user to run Docker commands without `sudo`.

```bash
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker "$USER"
newgrp docker
```

If Docker still says permission denied, log out and log back in.

Verify:

```bash
docker --version
docker info
docker run hello-world
```

## kubectl

kubectl is used to talk to the local Kubernetes cluster.

Install:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
```

Verify:

```bash
kubectl version --client
```

## Helm

Helm is used to package the Kubernetes deployment for the starter app.

Install:

```bash
sudo apt-get install -y curl gpg apt-transport-https
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
```

Verify:

```bash
helm version
```

## Minikube

Minikube is used to run a small Kubernetes cluster on your own machine.

Install:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```

Verify:

```bash
minikube version
```

You do not need to start Minikube manually for this project. `make setup` starts the `devops-starter-kit` Minikube profile for you.

## Final Verification

From the repository root, run:

```bash
./scripts/verify-dependencies.sh
```

If this succeeds, your machine has the tools needed for:

```bash
make setup
make verify
make open-app
```

## Official Installation References

- Git: https://git-scm.com/install/linux
- Java: https://adoptium.net/installation/linux
- Docker: https://docs.docker.com/engine/install/ubuntu/
- Docker post-install: https://docs.docker.com/engine/install/linux-postinstall/
- kubectl: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
- Helm: https://helm.sh/docs/intro/install/
- Minikube: https://minikube.sigs.k8s.io/docs/start/
