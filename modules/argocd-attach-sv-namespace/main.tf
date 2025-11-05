locals {
  argocd_cluster_config = {
    "bearerToken" = kubernetes_secret.argocd-token.data.token
    "tlsClientConfig" = {
      "insecure" = true
    }
  }
  argo_namespace = coalesce(var.argocd_namespace, var.namespace)

  
}

resource "kubernetes_service_account" "argo-cd-sa" {
  metadata {
    name = var.sa_name
    namespace = local.argo_namespace
  }
}

resource "kubernetes_secret" "argocd-token" {
  metadata {
    name = "${var.sa_name}-sa-token"
    namespace = local.argo_namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.argo-cd-sa.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}


resource "kubernetes_manifest" "argo-cd-role-binding" {

  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "RoleBinding"
    "metadata" = {
      "name" = "${var.sa_name}-role-binding"
      "namespace" = var.namespace
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = var.role_type
      "name" = var.role_name
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = kubernetes_service_account.argo-cd-sa.metadata[0].name
        "namespace" =  local.argo_namespace
      }
    ]
  }
}


resource "kubernetes_secret" "argocd-namespace-register" {
  metadata {
    name = "${var.namespace}-cluster-secret"
    namespace = var.argocd_namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
    
  }
  data = {
      "name" = var.namespace
      "config" = jsonencode(local.argocd_cluster_config)
      "namespaces" = var.namespace
      "server" = "https://kubernetes.default.svc.cluster.local:443"
  }
  type = "Opaque"
}
