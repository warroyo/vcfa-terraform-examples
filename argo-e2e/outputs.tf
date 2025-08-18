output "argo_ip" {
  value = module.argocd-instance.server_ip
}

output "argo_password" {
  value = module.argocd-instance.admin_password
  sensitive = true
}