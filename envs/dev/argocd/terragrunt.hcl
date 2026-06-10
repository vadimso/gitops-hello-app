terraform {
  source = "../../../modules/argocd"
}

inputs = {
  argocd_version = "5.51.6"
  git_repo_url   = get_env("GIT_REPO_URL", "https://github.com/YOUR_USERNAME/gitops-hello-app.git")
}
