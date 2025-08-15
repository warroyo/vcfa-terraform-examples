locals {
  cluster_name = "gitops-1"
}
data "vcfa_supervisor_namespace" "supervisor_namespace" {
  name         = var.namespace
  project_name = "default-project"
}



module "vks" {
  source = "../modules/vks-cluster"
  name = local.cluster_name
  namespace = data.vcfa_supervisor_namespace.supervisor_namespace.name
}

module "argo-attach" {
  source = "../modules/argo-attach-cluster"
  cluster_name = local.cluster_name
  kubeconfig = module.vks.kubeconfig
  namespace = data.vcfa_supervisor_namespace.supervisor_namespace.name
}