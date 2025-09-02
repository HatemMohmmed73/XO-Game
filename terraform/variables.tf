# XO Game - Terraform Variables

variable "namespace" {
  description = "Kubernetes namespace for XO Game"
  type        = string
  default     = "xo-game"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "xo-game"
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "xo-game:latest"
}

variable "postgres_image" {
  description = "PostgreSQL Docker image"
  type        = string
  default     = "postgres:15-alpine"
}

variable "postgres_replicas" {
  description = "Number of PostgreSQL replicas"
  type        = number
  default     = 3
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 8
}

variable "min_replicas" {
  description = "Minimum number of replicas for HPA"
  type        = number
  default     = 4
}

variable "max_replicas" {
  description = "Maximum number of replicas for HPA"
  type        = number
  default     = 16
}

variable "cpu_target" {
  description = "CPU target utilization for HPA"
  type        = number
  default     = 60
}

variable "memory_target" {
  description = "Memory target utilization for HPA"
  type        = number
  default     = 70
}

variable "storage_size" {
  description = "Size of shared storage"
  type        = string
  default     = "20Gi"
}

variable "postgres_storage_size" {
  description = "Size of PostgreSQL storage"
  type        = string
  default     = "10Gi"
}

variable "environment" {
  description = "Environment (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "xo_game"
}

variable "db_user" {
  description = "Database user"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "postgres"
  sensitive   = true
}
