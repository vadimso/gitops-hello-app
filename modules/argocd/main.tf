terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Install ArgoCD using Helm
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_version

  values = [
    yamlencode({
      applicationSet = {
        enabled = true
      }
      configs = {
        params = {
          "applicationsetcontroller.enable.leader.election" = false
        }
      }
    })
  ]
}

# Create ArgoCD Application
resource "kubernetes_manifest" "hello_app_application" {
  depends_on = [helm_release.argocd]

  manifest = yamldecode(templatefile("${path.module}/hello-app.yaml.tpl", {
    repo_url = var.git_repo_url
  }))
}

variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.6"
}

variable "git_repo_url" {
  description = "Git repository URL for ArgoCD to sync from"
  type        = string
  default     = "https://github.com/YOUR_USERNAME/gitops-hello-app.git"
}

output "argocd_namespace" {
  value = helm_release.argocd.namespace
}

output "argocd_release_status" {
  value = helm_release.argocd.status
}
