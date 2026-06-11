variable "cluster_name" {
  description = "Name of the kind cluster"
  type        = string
  default     = "demo"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.28.0"
}

variable "api_server_port" {
  description = "API server port"
  type        = number
  default     = 6443
}
