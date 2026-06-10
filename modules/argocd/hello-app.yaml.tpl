apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: hello-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${repo_url}
    targetRevision: main
    path: charts/hello-app
  destination:
    server: https://kubernetes.default.svc
    namespace: hello-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
