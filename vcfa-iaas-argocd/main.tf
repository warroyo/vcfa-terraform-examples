locals {
  cluster_name = "vcfa"
  kubeconfig = base64decode(var.kubeconfig)
}

data "vcfa_supervisor_namespace" "supervisor_namespace" {
  name         = var.namespace
  project_name = "default-project"
}


module "argo-attach" {
  source = "../modules/argo-attach-cluster"
  cluster_name = local.cluster_name
  kubeconfig = local.kubeconfig
  namespace = data.vcfa_supervisor_namespace.supervisor_namespace.name
  token_auth = true
}