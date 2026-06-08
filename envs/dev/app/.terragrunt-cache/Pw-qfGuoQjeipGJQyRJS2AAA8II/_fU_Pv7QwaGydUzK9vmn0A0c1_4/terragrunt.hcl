terraform {
  source = "../../../modules/app"
}

inputs = {
  name     = "hello-app"
  image    = "hashicorp/http-echo"
  replicas = 2
  port     = 5678
}
