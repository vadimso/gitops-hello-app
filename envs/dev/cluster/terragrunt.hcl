terraform {
  source = "../../../modules/cluster"
}

inputs = {
  cluster_name        = "demo"
  kubernetes_version  = "v1.28.0"
  api_server_port     = 6443
}
