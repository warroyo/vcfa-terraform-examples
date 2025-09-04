locals {
  kubeconfig = yamldecode(sensitive(var.kubeconfig))
 
  cluster_config =  {
    bearerToken = var.token_auth ? local.kubeconfig["users"][0]["user"]["token"] : ""
    tlsClientConfig = {
      insecure = var.token_auth ? true : false
      caData = !var.token_auth ? local.kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"] : ""
      certData = !var.token_auth ? local.kubeconfig["users"][0]["user"]["client-certificate-data"] : ""
      keyData = !var.token_auth ? local.kubeconfig["users"][0]["user"]["client-key-data"] : ""
    }
  }
}




resource "kubernetes_secret" "argocd-cluster-register" {
  metadata {
    name = "${var.cluster_name}-cluster-secret"
    namespace = var.namespace
    labels = merge(var.labels,{"argocd.argoproj.io/secret-type" = "cluster"})
    
  }
  data = {
      "name" = var.cluster_name
      "config" = jsonencode(local.cluster_config)
      "clusterResources" = "true"
      "server" = local.kubeconfig["clusters"][0]["cluster"]["server"]
  }
  type = "Opaque"
  
}
                                                                                                                                                                                                            