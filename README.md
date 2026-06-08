# GitOps Hello App

A complete GitOps deployment example using Terraform, Terragrunt, Helm, and ArgoCD to deploy a "Hello World" HTTP service on a local kind/minikube cluster.

## Architecture

- **Terraform Module** (`modules/app/`): Infrastructure-as-code module that generates Helm values
- **Terragrunt** (`envs/dev/app/`): Environment-specific configurations that instantiate the Terraform module
- **Helm Chart** (`charts/hello-app/`): Kubernetes manifests with deployment, service, and network policy
- **ArgoCD** (`argocd/`): GitOps continuous deployment manifest

## Prerequisites

- Docker (for kind)
- kubectl
- kind
- Helm (optional, but recommended)
- Terragrunt
- Terraform

## Quick Start (End-to-End)

### 1. Create a local Kubernetes cluster with kind

```bash
kind create cluster --name demo
```

Verify the cluster is running:
```bash
kubectl cluster-info
kubectl get nodes
```

### 2. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Wait for ArgoCD to be ready:
```bash
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

### 3. Push your repository to GitHub

Since ArgoCD needs to access your repository, push this project to GitHub:

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/gitops-hello-app.git
git branch -M main
git push -u origin main
```

### 4. Update the ArgoCD Application with your repository URL

Edit `argocd/hello-app.yaml` and replace `YOUR_USERNAME`:

```yaml
source:
  repoURL: https://github.com/YOUR_USERNAME/gitops-hello-app.git
```

### 5. Deploy the ArgoCD Application

```bash
kubectl apply -f argocd/hello-app.yaml
```

Verify the Application is created:
```bash
kubectl get application -n argocd
kubectl describe application hello-app -n argocd
```

### 6. Check the deployed application

```bash
# Wait for the deployment to be ready
kubectl wait --for=condition=ready pod -l app=hello-app -n hello-app --timeout=300s

# Verify resources
kubectl get all -n hello-app
kubectl get networkpolicy -n hello-app
```

### 7. Access the application

Port-forward to the service:
```bash
kubectl port-forward svc/hello-app 8080:5678 -n hello-app
```

Then access it in your browser or via curl:
```bash
curl http://localhost:8080
```

You should see: `Hello World`

## Project Structure

```
.
├── README.md                          # This file
├── argocd/
│   └── hello-app.yaml                # ArgoCD Application manifest
├── charts/
│   └── hello-app/
│       ├── Chart.yaml                # Helm chart metadata
│       ├── values.yaml               # Default values
│       └── templates/
│           ├── deployment.yaml       # Kubernetes Deployment with readiness probe
│           ├── service.yaml          # Kubernetes Service
│           └── networkpolicy.yaml    # Network policy for pod security
├── envs/
│   └── dev/
│       └── app/
│           └── terragrunt.hcl        # Terragrunt configuration for dev environment
├── modules/
│   └── app/
│       ├── main.tf                   # Terraform module - generates Helm values
│       ├── outputs.tf                # Module outputs
│       ├── variables.tf              # Module variables
│       └── templates/
│           └── values.yaml.tpl       # Template for Helm values file
└── .github/
    └── workflows/
        └── helm-lint.yaml            # GitHub Actions workflow for chart linting
```

## Configuration Details

### Helm Chart Values

The default configuration (`charts/hello-app/values.yaml`) specifies:

- **Image**: `hashicorp/http-echo:1.0` (lightweight HTTP echo service)
- **Replicas**: 2
- **Port**: 5678
- **Resource Requests**: 50m CPU, 64Mi memory
- **Resource Limits**: 200m CPU, 128Mi memory

### Readiness Probe

The deployment includes a TCP socket readiness probe:
- Initial delay: 5 seconds
- Period: 10 seconds

This ensures the container is ready to accept traffic before the service directs traffic to it.

### Network Policy

The NetworkPolicy allows ingress from all namespaces within the cluster, providing basic pod-to-pod security.

## Terraform Module

The Terraform module in `modules/app/` accepts:

- `name`: Application name
- `image`: Container image
- `replicas`: Number of replicas
- `port`: Container port

The module generates a Helm values file that gets templated into the chart.

### Example Usage (via Terragrunt)

```hcl
terraform {
  source = "../../../modules/app"
}

inputs = {
  name     = "hello-app"
  image    = "hashicorp/http-echo"
  replicas = 2
  port     = 5678
}
```

## CI/CD Pipeline

The project includes a GitHub Actions workflow (`.github/workflows/helm-lint.yaml`) that:

1. Lints the Helm chart on every push and PR
2. Validates chart syntax and structure
3. Ensures best practices are followed

### Running Helm Lint Locally

```bash
helm lint charts/hello-app/
```

## Troubleshooting

### ArgoCD Application shows "OutOfSync"

Ensure your git repository URL in `argocd/hello-app.yaml` is correct and accessible.

### No pods are running in hello-app namespace

Check the ArgoCD Application status:
```bash
kubectl describe application hello-app -n argocd
```

### Port-forward connection refused

Ensure the pod is in "Ready" state:
```bash
kubectl get pods -n hello-app
```

If the pod is not ready, check logs:
```bash
kubectl logs -n hello-app -l app=hello-app
```

## Cleanup

To remove everything:

```bash
# Delete the ArgoCD Application (this cascades to the hello-app namespace)
kubectl delete application hello-app -n argocd

# Optionally delete the entire cluster
kind delete cluster --name demo
```

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)