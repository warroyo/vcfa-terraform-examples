output "server_ip" {
  value = data.kubernetes_service.argocd.status.0.load_balancer.0.ingress.0.ip
}

output "admin_password" {
  value = data.kubernetes_secret.admin-password.data.password
  sensitive = true
}