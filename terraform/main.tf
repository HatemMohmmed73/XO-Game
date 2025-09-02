# XO Game - Complete Infrastructure as Code
# This creates a full Kubernetes setup with monitoring, logging, and CI/CD

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Configure Kubernetes Provider
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create namespace
resource "kubernetes_namespace" "xo_game" {
  metadata {
    name = "xo-game"
    labels = {
      app = "xo-game"
      environment = "production"
    }
  }
}

# Create shared storage
resource "kubernetes_persistent_volume" "shared_storage" {
  metadata {
    name = "xo-game-shared-storage"
    labels = {
      app = "xo-game"
      storage = "shared"
    }
  }
  spec {
    capacity = {
      storage = "20Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name = "shared-storage"
    persistent_volume_source {
      host_path {
        path = "/tmp/xo-game-shared"
        type = "DirectoryOrCreate"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "shared_data" {
  metadata {
    name = "xo-game-shared-data"
    namespace = kubernetes_namespace.xo_game.metadata[0].name
    labels = {
      app = "xo-game"
      storage = "shared"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "shared-storage"
    resources {
      requests = {
        storage = "20Gi"
      }
    }
  }
}

# Create storage class
resource "kubernetes_storage_class" "shared_storage" {
  metadata {
    name = "shared-storage"
    labels = {
      app = "xo-game"
      storage = "shared"
    }
  }
  storage_provisioner = "k8s.io/host-path"
  volume_binding_mode = "Immediate"
  allow_volume_expansion = true
}

# PostgreSQL ConfigMap
resource "kubernetes_config_map" "postgres_config" {
  metadata {
    name = "postgres-config"
    namespace = kubernetes_namespace.xo_game.metadata[0].name
    labels = {
      app = "xo-game"
      component = "postgres-cluster"
    }
  }
  data = {
    "postgresql.conf" = <<-EOT
      # Basic settings
      listen_addresses = '*'
      port = 5432
      max_connections = 100
      
      # Memory settings
      shared_buffers = 256MB
      effective_cache_size = 1GB
      maintenance_work_mem = 64MB
      
      # WAL settings for replication
      wal_level = replica
      max_wal_senders = 3
      max_replication_slots = 3
      
      # Replication settings
      hot_standby = on
      hot_standby_feedback = on
      
      # Logging
      log_statement = 'all'
      log_destination = 'stderr'
      logging_collector = on
      log_directory = 'pg_log'
      log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
    EOT
  }
}

# PostgreSQL StatefulSet
resource "kubernetes_stateful_set" "postgres_cluster" {
  metadata {
    name = "xo-game-postgres-cluster"
    namespace = kubernetes_namespace.xo_game.metadata[0].name
    labels = {
      app = "xo-game"
      component = "postgres-cluster"
    }
  }
  spec {
    service_name = "xo-game-postgres-cluster-service"
    replicas = 3
    selector {
      match_labels = {
        app = "xo-game"
        component = "postgres-cluster"
      }
    }
    template {
      metadata {
        labels = {
          app = "xo-game"
          component = "postgres-cluster"
        }
      }
      spec {
        container {
          name = "postgres-primary"
          image = "postgres:15-alpine"
          env {
            name = "POSTGRES_DB"
            value = "xo_game"
          }
          env {
            name = "POSTGRES_PASSWORD"
            value = "postgres"
          }
          env {
            name = "POSTGRES_USER"
            value = "postgres"
          }
          env {
            name = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }
          port {
            container_port = 5432
            protocol = "TCP"
          }
          resources {
            requests = {
              memory = "1Gi"
              cpu = "500m"
            }
            limits = {
              memory = "2Gi"
              cpu = "1000m"
            }
          }
          liveness_probe {
            exec {
              command = ["/usr/local/bin/pg_isready", "-U", "postgres"]
            }
            failure_threshold = 5
            period_seconds = 10
            timeout_seconds = 5
          }
          readiness_probe {
            exec {
              command = ["/usr/local/bin/pg_isready", "-U", "postgres"]
            }
            failure_threshold = 3
            period_seconds = 5
            timeout_seconds = 3
          }
          volume_mount {
            name = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
          volume_mount {
            name = "postgres-config"
            mount_path = "/etc/postgresql/postgresql.conf"
            sub_path = "postgresql.conf"
          }
        }
        volume {
          name = "postgres-config"
          config_map {
            name = kubernetes_config_map.postgres_config.metadata[0].name
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "postgres-data"
      }
      spec {
        access_modes = ["ReadWriteOnce"]
        storage_class_name = "standard"
        resources {
          requests = {
            storage = "10Gi"
          }
        }
      }
    }
  }
}

# PostgreSQL Service
resource "kubernetes_service" "postgres_cluster" {
  metadata {
    name = "xo-game-postgres-cluster-service"
    namespace = kubernetes_namespace.xo_game.metadata[0].name
    labels = {
      app = "xo-game"
      component = "postgres-cluster"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      port = 5432
      target_port = 5432
      protocol = "TCP"
      name = "postgres"
    }
    selector = {
      app = "xo-game"
      component = "postgres-cluster"
    }
    session_affinity = "ClientIP"
    session_affinity_config {
      client_ip {
        timeout_seconds = 10800
      }
    }
  }
}

# App Deployment
resource "kubernetes_deployment" "stress_test" {
  metadata {
    name = "xo-game-stress-test"
    namespace = kubernetes_namespace.xo_game.metadata[0].name
    labels = {
      app = "xo-game"
      component = "app"
      test = "stress"
    }
  }
  spec {
    replicas = 8
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_surge = 2
        max_unavailable = 1
      }
    }
    selector {
      match_labels = {
        app = "xo-game"
        component = "app"
        test = "stress"
      }
    }
    template {
      metadata {
        labels = {
          app = "xo-game"
          component = "app"
          test = "stress"
        }
      }
      spec {
        container {
          name = "xo-game-app"
          image = "xo-game:latest"
          image_pull_policy = "Never"
          port {
            container_port = 8080
            protocol = "TCP"
          }
          env {
            name = "DB_HOST"
            value = "xo-game-postgres-cluster-service"
          }
          env {
            name = "DB_NAME"
            value = "xo_game"
          }
          env {
            name = "DB_PASSWORD"
            value = "postgres"
          }
          env {
            name = "DB_PORT"
            value = "5432"
          }
          env {
            name = "DB_USER"
            value = "postgres"
          }
          env {
            name = "NODE_ENV"
            value = "production"
          }
          env {
            name = "SHARED_DATA_PATH"
            value = "/shared-data"
          }
          resources {
            requests = {
              memory = "512Mi"
              cpu = "500m"
            }
            limits = {
              memory = "1Gi"
              cpu = "1000m"
            }
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds = 10
            timeout_seconds = 5
            failure_threshold = 3
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 5
            period_seconds = 5
            timeout_seconds = 3
            failure_threshold = 3
          }
          startup_probe {
            http_get {
              path = "/health"
              port = 8080
            }
            initial_delay_seconds = 10
            period_seconds = 5
            timeout_seconds = 3
            failure_threshold = 10
          }
          volume_mount {
            name = "shared-data"
            mount_path = "/shared-data"
          }
        }
        volume {
          name = "shared-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.shared_data.metadata[0].name
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

# App Service
resource "kubernetes_service" "stress_test" {
  metadata {
    name = "xo-game-stress-test-service"
    namespace = kubernetes_namespace.xo_game.metadata[0].name
    labels = {
      app = "xo-game"
      test = "stress"
    }
  }
  spec {
    type = "ClusterIP"
    port {
      port = 8080
      target_port = 8080
      protocol = "TCP"
      name = "http"
    }
    selector = {
      app = "xo-game"
      test = "stress"
    }
  }
}

# Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa" {
  metadata {
    name = "xo-game-hpa"
    namespace = kubernetes_namespace.xo_game.metadata[0].name
    labels = {
      app = "xo-game"
    }
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = kubernetes_deployment.stress_test.metadata[0].name
    }
    min_replicas = 4
    max_replicas = 16
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type = "Utilization"
          average_utilization = 60
        }
      }
    }
    metric {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type = "Utilization"
          average_utilization = 70
        }
      }
    }
    behavior {
      scale_up {
        stabilization_window_seconds = 60
        select_policy = "Max"
        policy {
          type = "Pods"
          value = 2
          period_seconds = 60
        }
      }
      scale_down {
        stabilization_window_seconds = 300
        select_policy = "Min"
        policy {
          type = "Pods"
          value = 1
          period_seconds = 60
        }
      }
    }
  }
}
