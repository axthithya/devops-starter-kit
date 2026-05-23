# DevOps Starter Kit

![GitHub Actions](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088ff)
![DockerHub](https://img.shields.io/badge/Registry-DockerHub-2496ed)
![Kubernetes](https://img.shields.io/badge/Runtime-Kubernetes-326ce5)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-ef7b4d)
![Quality](https://img.shields.io/badge/Quality-SonarCloud-4e9bcd)

A beginner-friendly DevOps starter platform for Spring Boot applications.

It shows the full path from code to container image to Kubernetes deployment using GitHub Actions, DockerHub, Helm, ArgoCD, and Minikube. You can first run the demo exactly as-is, then connect your own accounts and application when you are ready.

## 🚀 Quick Start

There are two phases:

| Phase | Goal | You need accounts? |
| --- | --- | --- |
| **Phase 1: Check your machine** | Make sure your system can run the DevOps stack correctly | No |
| **Phase 2: Use your own project** | Turn the starter kit into your real CI/CD and GitOps workflow | Yes |

Phase 1 is only about testing the platform on your machine. The default demo image and config are enough.

Phase 2 is where you connect GitHub Actions, DockerHub, optional SonarCloud scanning, and your own Spring Boot app so deployments happen from Git.

---

### Phase 1: Local Demo

This phase checks that your machine has everything needed to run the DevOps platform correctly.

It will:

- Validate the required tools.
- Start local Kubernetes with Minikube.
- Install ArgoCD, which keeps Kubernetes in sync with Git.
- Deploy the demo application automatically.
- Prove Docker, Kubernetes, Helm, ArgoCD, and GitOps work together on your machine.

#### 1. Clone the repository

```bash
git clone https://github.com/axthithya/devops-starter-kit.git
cd devops-starter-kit
cp .env.example .env
```

For the first run, leave `.env` unchanged. You do not need your own GitHub repository, DockerHub image, or SonarCloud project yet.

> 🛠️ **First time setting up DevOps tools?**
>
> If `make setup` reports missing dependencies like Docker, kubectl, Helm, or Minikube, follow the [Dependency Installation Guide](./DEPENDENCIES.md). It walks through the Ubuntu setup commands one tool at a time.

#### 2. Prepare the local DevOps stack

```bash
make setup
```

What this does: checks your tools, starts Minikube, installs ArgoCD, and registers the demo app.

Why you run it: this prepares a local Kubernetes environment without asking you to wire everything together by hand.

Success means you see:

```text
OK  Setup completed
```

#### 3. Verify everything is healthy

```bash
make verify
```

What this does: checks Docker, Kubernetes, ArgoCD, the app deployment, and the app service.

Why you run it: this proves the DevOps stack is working correctly on your machine.

Success means you see:

```text
OK  All health checks passed
```

If ArgoCD is still syncing, wait a minute and run `make verify` again.

#### 4. Open the demo app

```bash
make open-app
```

What this does: prints the local URL for the app running inside Kubernetes.

Why you run it: this proves you can reach the deployed application through the local Kubernetes service.

Open the printed `Application URL` in your browser.

✅ At this point, your local DevOps environment is ready.

---

### Phase 2: Your Real Project

This phase turns the starter kit into your own real CI/CD and GitOps workflow.

You will connect your own GitHub repository, DockerHub image, optional SonarCloud project, and application code. After that, a normal `git push` can build, publish, and deploy your app.

#### 5. Connect your own accounts

| Account or setting | What it enables |
| --- | --- |
| GitHub repository | Gives GitHub Actions a place to run CI/CD for your code |
| GitHub Secrets | Stores private tokens safely for the workflow |
| DockerHub | Stores the Docker image that Kubernetes will run |
| SonarCloud | Adds optional code quality scanning |

Point your clone at your own repository:

```bash
git remote set-url origin https://github.com/<your-github-username>/<your-repository>.git
```

Then update `.env` with your repository and image values:

```bash
GIT_REPO_URL=https://github.com/<your-github-username>/<your-repository>.git
DOCKERHUB_USERNAME=<your-dockerhub-username>
DOCKER_IMAGE_NAME=devops-starter-kit
SONAR_ORGANIZATION=your-sonarcloud-organization
SONAR_PROJECT_KEY=your-sonarcloud-project-key
```

Refresh ArgoCD after changing `.env`:

```bash
make deploy
```

For the full GitHub Secrets and variables list, see [Quick Start: Connect your own accounts](QUICKSTART.md#5-connect-your-own-accounts).

#### 6. Replace the demo app later

The starter application lives in `app/`. Keep it while learning, then replace it with your own Spring Boot app when you are ready.

Short version:

- `app/Dockerfile` tells Docker how to package the app.
- `helm/starter-app/` tells Kubernetes how to run the app.
- `.env` gives the local scripts your app, namespace, and image values.

#### 7. Deploy from git push

The flow is:

```text
code change -> git push -> GitHub Actions -> Docker image -> ArgoCD -> Kubernetes deployment
```

GitHub Actions builds and tests the app. If DockerHub is configured, it publishes a Docker image. ArgoCD then watches Git and keeps Kubernetes updated with the desired image and Helm settings.

See the [CI/CD Flow explanation](ARCHITECTURE.md#cicd-flow) for the beginner-friendly version of what happens after a push.

## Helpful Guides

| Guide | When to use it |
| --- | --- |
| [Quick Start](QUICKSTART.md) | You want a slower, step-by-step first run |
| [Dependency Installation Guide](DEPENDENCIES.md) | `make setup` says Docker, kubectl, Helm, Minikube, Git, or Java is missing |
| [Architecture Overview](ARCHITECTURE.md) | You want to understand ArgoCD, GitOps, Helm, and the CI/CD flow |

## Screenshots

| Local setup | ArgoCD health |
| --- | --- |
| ![Local setup terminal](docs/screenshots/local-setup.svg) | ![ArgoCD healthy app](docs/screenshots/argocd-health.svg) |

## 🧰 Tech Stack

| Layer | Tooling |
| --- | --- |
| Application | Java 21, Spring Boot, Maven |
| Container | Docker, DockerHub |
| CI/CD | GitHub Actions |
| Code quality | SonarCloud |
| Kubernetes packaging | Helm |
| GitOps | ArgoCD |
| Local cluster | Minikube |
| Automation | Bash scripts, Makefile |

## 📁 Repository Layout

```text
.
|-- app/                    # Spring Boot application and Dockerfile
|-- argocd/                 # ArgoCD Application template and generated manifest
|-- helm/starter-app/       # Reusable Spring Boot Helm chart
|-- scripts/                # Setup, validation, bootstrap, health, cleanup
|-- docs/screenshots/       # README visual assets
|-- .github/workflows/      # GitHub Actions pipeline
|-- .env.example            # Copyable local configuration with demo defaults
|-- ARCHITECTURE.md         # Beginner-friendly architecture and CI/CD overview
|-- DEPENDENCIES.md         # Ubuntu dependency installation guide
|-- QUICKSTART.md           # Detailed first-run and account setup guide
|-- Makefile                # Beginner-friendly command surface
`-- README.md
```

## 🛠️ Make Commands

| Command | What it does |
| --- | --- |
| `make setup` | Checks dependencies, starts Minikube, installs ArgoCD, and deploys the demo app |
| `make verify` | Checks Docker, Kubernetes, ArgoCD, and the app health |
| `make open-app` | Prints the local URL for the deployed app |
| `make deploy` | Refreshes the ArgoCD Application after `.env` changes |
| `make minikube` | Starts or verifies the Minikube profile |
| `make argocd` | Installs or verifies ArgoCD and applies the Application |
| `make cleanup` | Removes app resources while keeping Minikube |
| `make cleanup-all` | Removes the app, ArgoCD, and the Minikube profile |
| `make test` | Runs Maven verification for the Spring Boot app |
| `make docker-build` | Builds the Docker image locally using `.env` values |
| `make helm-template` | Renders the Helm chart locally using `.env` values |

## ✅ Required Tools

Primary support target: Ubuntu/Linux. Secondary target: WSL2 with Docker Desktop WSL integration enabled.

| Tool | Used for | Check |
| --- | --- | --- |
| Git | Cloning and pushing the repository | `git --version` |
| Java 21 | Building and testing the Spring Boot app | `java -version` |
| Docker | Building images and running Minikube's local containers | `docker info` |
| kubectl | Talking to Kubernetes | `kubectl version --client` |
| Helm | Packaging Kubernetes resources | `helm version` |
| Minikube | Running Kubernetes locally | `minikube version` |

Install help: [Dependency Installation Guide](DEPENDENCIES.md)

Check everything from the repository root:

```bash
./scripts/verify-dependencies.sh
```

## 🔄 Architecture and CI/CD

The core idea is GitOps: Git stores the desired deployment state, and ArgoCD keeps Kubernetes matching it.

For a visual overview and simple explanations of ArgoCD, Helm, Docker image publishing, and the deployment flow, read [Architecture Overview](ARCHITECTURE.md).

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `.env` missing | Commands create `.env` from `.env.example` automatically; you can also run `cp .env.example .env` yourself |
| Docker not reachable | Start Docker Engine/Desktop and verify `docker info` |
| WSL2 cannot reach Docker | Enable Docker Desktop WSL integration for your distro |
| Minikube fails to start | Check Docker is running, then run `minikube delete -p devops-starter-kit` and retry |
| ArgoCD Application is `Missing` | Verify your git `origin`, or set `GIT_REPO_URL` explicitly with `GIT_TARGET_REVISION` and `HELM_CHART_PATH` in `.env` |
| Image pull fails | Check DockerHub repo visibility and `DOCKERHUB_USERNAME`/`DOCKER_IMAGE_NAME` values |
| SonarCloud fails in CI | Confirm `SONAR_TOKEN`, `SONAR_ORGANIZATION`, and `SONAR_PROJECT_KEY` |
| GitOps commit fails | Give GitHub Actions read/write workflow permissions or set `UPDATE_HELM_IMAGE_TAG=false` |
| NodePort collision | Leave `NODE_PORT` blank so Kubernetes chooses a free port |

## Cleanup

Remove the app and ArgoCD Application while keeping Minikube:

```bash
make cleanup
```

Remove the app, ArgoCD, and Minikube profile:

```bash
make cleanup-all
```

## FAQ

**Can I use this for another Spring Boot app?**

Yes. Replace the code under `app/`, keep the Dockerfile or adapt it, then update `.env` and Helm values.

**Do I need to use GitHub's template button first?**

No. Clone this repository directly. Create or fork your own GitHub repository only when you are ready to push your customized copy and run your own CI/CD.

**Do I need to manually edit Kubernetes YAML?**

For the normal path, no. Configure `.env` locally and GitHub variables/secrets in CI.

**Why does the workflow update `helm/starter-app/values.yaml`?**

That gives ArgoCD a Git change to sync after a new Docker image is published. Disable it with `UPDATE_HELM_IMAGE_TAG=false`.

**Can I use a private DockerHub repository?**

Yes, but your Kubernetes cluster needs image pull credentials. Add `imagePullSecrets` in Helm values.

**Does this replace production Kubernetes?**

No. Minikube is for local learning and demos. The same Helm and ArgoCD pattern can be adapted to managed clusters.

## Contributing

Contributions are welcome. Keep changes beginner-friendly and automation-first:

1. Open an issue or describe the problem in your pull request.
2. Keep defaults safe for local Minikube.
3. Avoid hardcoded personal values outside the documented demo defaults.
4. Update docs when changing setup behavior.
5. Run `make test` and `make helm-template` before opening a pull request.

## License

This project is released under the MIT License. See [LICENSE](LICENSE).
