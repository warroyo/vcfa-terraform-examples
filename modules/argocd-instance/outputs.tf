output "server_ip" {
  value = data.kubernetes_service.argocd.status.0.load_balancer.0.ingress.0.ip
}

output "admin_password" {
  value = local.argo_password
  sensitive = true
}