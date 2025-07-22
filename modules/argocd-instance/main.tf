locals {
  argocd_cluster_config = {
    "bearerToken" = kubernetes_secret.argocd-token.data.token
    "tlsClientConfig" = {
      "insecure" = true
    }
  }
}
resource "kubernetes_manifest" "argo-cd-instance" {

  manifest = {
    "apiVersion" = "argocd-service.vsphere.vmware.com/v1alpha1"
    "kind" = "ArgoCD"
    "metadata" = {
      "name" = var.name
      "namespace" = var.namespace
    }
    "spec" = {
      "version" = "2.14.13+vmware.1-vks.1"
    }
  }
}

resource "kubernetes_service_account" "argo-cd-sa" {
  metadata {
    name = "argocd-manager"
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "argocd-token" {
  metadata {
    name = "argocd-manager-sa-token"
    namespace = var.namespace
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
      "name" = "argocd-manager-role-binding"
      "namespace" = var.namespace
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "edit" 
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = kubernetes_service_account.argo-cd-sa.metadata[0].name
        "namespace" =  var.namespace
      }
    ]
  }
}


resource "kubernetes_secret" "argocd-namespace-register" {
  metadata {
    name = "${var.namespace}-cluster-secret"
    namespace = var.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
    
  }
  data = {
      "name" = var.namespace
      "config" = jsonencode(local.argocd_cluster_config)
      "namespaces" = var.namespace
      "server" = "kubernetes.default.svc"
  }
  type = "Opaque"
}

data "kubernetes_service" "argocd" {
    metadata {
    name = "argocd-server"
    namespace = var.namespace
  }
  depends_on = [ kubernetes_manifest.argo-cd-instance ]
}