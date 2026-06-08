resource "local_file" "helm_values" {
  filename = "${path.root}/generated/${var.name}-values.yaml"

  content = templatefile(
    "${path.module}/templates/values.yaml.tpl",
    {
      name     = var.name
      image    = var.image
      replicas = var.replicas
      port     = var.port
    }
  )
}
