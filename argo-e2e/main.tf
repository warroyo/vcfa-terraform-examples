
module "supervisor_namespace" {
  source = "../modules/namespace"
  zone_name = var.zone_name
  region_name = var.region_name
  vpc_name = var.vpc_name
  name = var.namespace
  storage_limit = var.ns_storage_limit
}

module "argocd-instance" {
  source = "../modules/argocd-instance"
  name = "argocd-1"
  namespace = module.supervisor_namespace.namespace
}

module "bootstrap-ns" {
  source = "../modules/sup-ns-cluster-bootstrap"
  namespace = module.supervisor_namespace.namespace
  path = "./cluster-bootstrap/source"
  repo = "https://github.com/warroyo/vks-argocd-examples"
  depends_on = [ module.argocd-instance ]
}

module "vks" {
  source = "../modules/vks-cluster"
  name = var.cluster
  namespace = module.supervisor_namespace.namespace
  vmClass = var.vm_class
  cluster_class = var.cluster_class
}

module "argo-attach" {
  source = "../modules/argo-attach-cluster"
  cluster_name = var.cluster
  kubeconfig = module.vks.kubeconfig
  namespace = module.supervisor_namespace.namespace
  labels = {
    "type" = "vks"
  }
}

locals {
  kubeconfig = yamldecode(sensitive(module.vks.kubeconfig))
}

resource "kubernetes_manifest" "music-store" {
  depends_on = [ module.argocd-instance ]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name = "music-store"
      namespace = module.supervisor_namespace.namespace
    }
    spec = {
      project = "default"
      source = {
        repoURL = "https://github.com/NiranEC77/example-music-store-1"
        path = "./"
        targetRevision = "main"
        directory = {
          include = "k8s-*.yaml"
        }
      }
      destination = {
        server = local.kubeconfig["clusters"][0]["cluster"]["server"]
        namespace = "default"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}