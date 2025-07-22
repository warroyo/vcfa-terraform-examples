output "argocd_ip" {
  value = data.kubernetes_service.argocd.status.0.load_balancer.0.ingress.0.ip
}