# Quick Start Guide

This guide walks through the same setup as the README, but with a little more context.

Use it if this is your first time running the project or if you want to understand what each command is proving.

Back to: [README](README.md) | [Dependencies](DEPENDENCIES.md) | [Architecture](ARCHITECTURE.md)

## Phase 1: Check Your Machine

Phase 1 makes sure your system is ready to run the DevOps stack.

You do not need your own GitHub repository, DockerHub image, or SonarCloud project yet. The demo image and default `.env` values are enough for the first run.

### 1. Clone the repository

```bash
git clone https://github.com/axthithya/devops-starter-kit.git
cd devops-starter-kit
cp .env.example .env
```

What this does:

- Downloads the starter kit.
- Creates your local `.env` settings file.
- Keeps the first run on safe demo defaults.

### 2. Prepare the local DevOps stack

```bash
make setup
```

What this does:

- Checks that required tools are installed.
- Starts the `devops-starter-kit` Minikube profile.
- Creates the Kubernetes namespaces.
- Installs ArgoCD.
- Registers the demo app so ArgoCD can deploy it.

Why you run it:

This command prepares the local Kubernetes platform automatically. It saves you from manually installing ArgoCD, creating namespaces, and wiring the demo app into GitOps by hand.

Success means:

```text
OK  Setup completed
```

If this command reports missing tools, follow the [Dependency Installation Guide](DEPENDENCIES.md), then run `make setup` again.

### 3. Verify the setup

```bash
make verify
```

What this does:

- Checks Docker is reachable.
- Checks Kubernetes is running.
- Checks ArgoCD is available.
- Checks the ArgoCD Application exists.
- Checks the app deployment and service exist.

Why you run it:

This proves the DevOps stack works correctly on your machine.

Success means:

```text
OK  All health checks passed
```

ArgoCD may need a minute or two to finish syncing right after setup. If verification fails immediately after `make setup`, wait a moment and try again.

### 4. Open the demo app

```bash
make open-app
```

What this does:

- Asks Minikube for the local app URL.
- Prints an `Application URL`.
- Shows a port-forward fallback command if Minikube cannot resolve the URL automatically.

Why you run it:

This proves traffic can reach the application running inside Kubernetes.

Open the printed URL in your browser. Phase 1 is complete when the app responds.

## Phase 2: Use Your Own Project

Phase 2 turns the starter kit into your own CI/CD and GitOps workflow.

This is where you connect your GitHub repository, DockerHub account, optional SonarCloud project, and your own app code.

### 5. Connect your own accounts

Create a GitHub repository or fork, then point your local clone at it:

```bash
git remote set-url origin https://github.com/<your-github-username>/<your-repository>.git
```

Update `.env`:

```bash
GIT_REPO_URL=https://github.com/<your-github-username>/<your-repository>.git
DOCKERHUB_USERNAME=<your-dockerhub-username>
DOCKER_IMAGE_NAME=devops-starter-kit
SONAR_ORGANIZATION=your-sonarcloud-organization
SONAR_PROJECT_KEY=your-sonarcloud-project-key
```

Run this after changing `.env` so ArgoCD watches your repository and image:

```bash
make deploy
```

In GitHub, open `Settings -> Secrets and variables -> Actions`.

Also open `Settings -> Actions -> General -> Workflow permissions` and select `Read and write permissions`. This lets GitHub Actions commit the new Helm image tag for ArgoCD.

Add these repository secrets:

| Secret | What it enables |
| --- | --- |
| `DOCKER_USERNAME` | Lets GitHub Actions sign in to DockerHub |
| `DOCKER_PASSWORD` | Lets GitHub Actions publish your Docker image |
| `SONAR_TOKEN` | Lets GitHub Actions run SonarCloud analysis, only if you use SonarCloud |

Add these repository variables:

| Variable | Required | Example |
| --- | --- | --- |
| `SONAR_ORGANIZATION` | Only for SonarCloud | `my-sonar-org` |
| `SONAR_PROJECT_KEY` | Only for SonarCloud | `my-org_my-repo` |
| `DOCKER_IMAGE_NAME` | No | `devops-starter-kit` |
| `DOCKERHUB_REPOSITORY` | No | `my-dockerhub-user/devops-starter-kit` |
| `SONAR_HOST_URL` | No | `https://sonarcloud.io` |
| `UPDATE_HELM_IMAGE_TAG` | No | `true` |

If DockerHub secrets are missing, CI still builds and tests the app but skips Docker publishing and GitOps image tag updates.

If SonarCloud values are missing, CI skips the SonarCloud scan with a warning.

### 6. Replace the demo app

The demo app lives in `app/`.

When you are ready, replace that code with your own Spring Boot application.

Keep these pieces in mind:

- `app/Dockerfile` packages the app into a Docker image.
- `helm/starter-app/` tells Kubernetes how to run the image.
- `.env` gives local scripts values such as app name, namespace, and image name.

After replacing the app, run:

```bash
make test
make docker-build
make helm-template
```

These commands check the application build, Docker image build, and Helm rendering locally.

### 7. Push to main

```bash
git add .
git commit -m "configure starter kit"
git push origin main
```

The beginner version of the flow is:

```text
code change -> git push -> GitHub Actions -> Docker image -> ArgoCD -> Kubernetes deployment
```

After the first successful pipeline run:

```bash
make verify
make open-app
```

That checks whether your local Kubernetes environment picked up the latest desired app state from Git.

## Optional: ArgoCD UI

ArgoCD is the GitOps controller. In simple terms, it watches Git and keeps Kubernetes matching what Git says should be running.

Port-forward the ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Get the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

Open `https://localhost:8080` and log in with username `admin`.
