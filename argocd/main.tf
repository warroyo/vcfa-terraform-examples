
locals {
  argocd_cluster_config = {
    "bearerToken" = kubernetes_secret.argocd-token.data.token
    "tlsClientConfig" = {
      "insecure" = true
    }
  }
  region_name = "west"
  vpc_name = "west-Default-VPC"
  zone_name = "z-wld-a"
}

module "supervisor_namespace" {
  source = "../modules/namespace"
  zone_name = local.zone_name
  region_name = local.region_name
  vpc_name = local.vpc_name
}



resource "kubernetes_manifest" "argo-cd-instance" {

  manifest = {
    "apiVersion" = "argocd-service.vsphere.vmware.com/v1alpha1"
    "kind" = "ArgoCD"
    "metadata" = {
      "name" = "argocd-1"
      "namespace" =  module.supervisor_namespace.namespace
    }
    "spec" = {
      "version" = "2.14.13+vmware.1-vks.1"
    }
  }
}

resource "kubernetes_service_account" "argo-cd-sa" {
  metadata {
    name = "argocd-manager"
    namespace = module.supervisor_namespace.namespace
  }
}

resource "kubernetes_secret" "argocd-token" {
  metadata {
    name = "argocd-manager-sa-token"
    namespace = module.supervisor_namespace.namespace
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
      "namespace" =  module.supervisor_namespace.namespace
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
        "namespace" =  module.supervisor_namespace.namespace
      }
    ]
  }
}


resource "kubernetes_secret" "argocd-namespace-register" {
  metadata {
    name = "${module.supervisor_namespace.namespace}-cluster-secret"
    namespace = module.supervisor_namespace.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
    
  }
  data = {
      "name" = module.supervisor_namespace.namespace
      "config" = jsondecode(local.argocd_cluster_config)
      "namespaces" = module.supervisor_namespace.namespace
      "server" = "kubernetes.default.svc"
  }
  type = "Opaque"
}
