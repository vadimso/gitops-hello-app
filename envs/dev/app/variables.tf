variable "name" {
  description = "Application name"
  type        = string
  default     = "hello-app"
}

variable "image" {
  description = "Container image"
  type        = string
  default     = "hashicorp/http-echo"
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

variable "port" {
  description = "Container port"
  type        = number
  default     = 5678
}
