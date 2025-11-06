locals {
  argo_password = ( 
    length(trimspace(var.password)) > 0
    ? var.password
    : data.kubernetes_secret.admin-password.data.password
  )
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
      "applicationSet" = {
        "enabled": true
      }
      "version" = "2.14.15+vmware.1-vks.1"
    }
  }
  wait {
    fields = {
      //need to check the reason since the status is always true
      "status.conditions[2].reason" = "ReconcileSucceeded"
    }
  }
}

module "namespace-register" {
  source = "../argocd-attach-sv-namespace"
  namespace = var.namespace
  argocd_namespace = var.namespace
}

resource "kubernetes_secret_v1_data" "update-admin-secret" {
      count = var.password != "" ? 1 : 0 
      metadata {
        name      = "argocd-secret" 
        namespace = var.namespace
      }

      data = {
        "admin.password" = bcrypt(var.password)
        "admin.passwordMtime" = timestamp()
      }
      force = true
      depends_on = [ kubernetes_manifest.argo-cd-instance ]
}

data "kubernetes_service" "argocd" {
  metadata {
    name = "argocd-server"
    namespace = var.namespace
  }
  depends_on = [ kubernetes_manifest.argo-cd-instance ]
}

data "kubernetes_secret" "admin-password" {
  metadata {
    name = "argocd-initial-admin-secret"
    namespace = var.namespace
  }

  depends_on =  [ kubernetes_manifest.argo-cd-instance ]
}