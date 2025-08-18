locals {
  kubeconfig = yamldecode(sensitive(var.kubeconfig))
  argocd_cluster_config = {
    "tlsClientConfig" = {
      "caData" = local.kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"],
      "certData" = local.kubeconfig["users"][0]["user"]["client-certificate-data"]
      "keyData" = local.kubeconfig["users"][0]["user"]["client-key-data"]
    }
  }
}




resource "kubernetes_secret" "argocd-cluster-register" {
  metadata {
    name = "${var.cluster_name}-cluster-secret"
    namespace = var.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
    
  }
  data = {
      "name" = var.cluster_name
      "config" = jsonencode(local.argocd_cluster_config)
      "clusterResources" = "true"
      "server" = local.kubeconfig["clusters"][0]["cluster"]["server"]
  }
  type = "Opaque"
  
}
                                                                                                                                                                                                            