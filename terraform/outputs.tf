# XO Game - Terraform Outputs

output "namespace" {
  description = "Kubernetes namespace"
  value       = kubernetes_namespace.xo_game.metadata[0].name
}

output "postgres_service" {
  description = "PostgreSQL service endpoint"
  value       = "${kubernetes_service.postgres_cluster.metadata[0].name}.${kubernetes_namespace.xo_game.metadata[0].name}.svc.cluster.local:5432"
}

output "app_service" {
  description = "Application service endpoint"
  value       = "${kubernetes_service.stress_test.metadata[0].name}.${kubernetes_namespace.xo_game.metadata[0].name}.svc.cluster.local:8080"
}

output "app_service_ip" {
  description = "Application service IP"
  value       = kubernetes_service.stress_test.spec[0].cluster_ip
}

output "postgres_service_ip" {
  description = "PostgreSQL service IP"
  value       = kubernetes_service.postgres_cluster.spec[0].cluster_ip
}

output "hpa_name" {
  description = "Horizontal Pod Autoscaler name"
  value       = kubernetes_horizontal_pod_autoscaler_v2.hpa.metadata[0].name
}

output "deployment_name" {
  description = "Application deployment name"
  value       = kubernetes_deployment.stress_test.metadata[0].name
}

output "statefulset_name" {
  description = "PostgreSQL StatefulSet name"
  value       = kubernetes_stateful_set.postgres_cluster.metadata[0].name
}

output "shared_storage_pvc" {
  description = "Shared storage PVC name"
  value       = kubernetes_persistent_volume_claim.shared_data.metadata[0].name
}

output "kubectl_commands" {
  description = "Useful kubectl commands"
  value = {
    get_pods = "kubectl get pods -n ${kubernetes_namespace.xo_game.metadata[0].name}"
    get_services = "kubectl get services -n ${kubernetes_namespace.xo_game.metadata[0].name}"
    get_hpa = "kubectl get hpa -n ${kubernetes_namespace.xo_game.metadata[0].name}"
    logs = "kubectl logs -l app=${var.app_name},test=stress -n ${kubernetes_namespace.xo_game.metadata[0].name}"
    scale = "kubectl scale deployment ${kubernetes_deployment.stress_test.metadata[0].name} --replicas=10 -n ${kubernetes_namespace.xo_game.metadata[0].name}"
  }
}
