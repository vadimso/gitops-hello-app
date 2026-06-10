remote_state {
  backend = "local"
  config = {
    path = "${get_terragrunt_dir()}/.terraform/terraform.tfstate"
  }
}

locals {
  env = get_env("TF_VAR_environment", "dev")
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = templatefile("${get_terragrunt_dir()}/../provider.hcl", {
    region = get_env("AWS_REGION", "us-east-1")
  })
}
