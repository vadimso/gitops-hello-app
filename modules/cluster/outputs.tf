output "cluster_name" {
  description = "Name of the created kind cluster"
  value       = kind_cluster.main.name
}

output "cluster_id" {
  description = "ID of the created kind cluster"
  value       = kind_cluster.main.id
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = kind_cluster.main.kubeconfig
  sensitive   = true
}

output "endpoint" {
  description = "Kubernetes API server endpoint"
  value       = "https://127.0.0.1:${var.api_server_port}"
}
