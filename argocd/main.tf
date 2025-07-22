
locals {
  region_name = var.region_name
  vpc_name = var.vpc_name
  zone_name = var.zone_name
}

module "supervisor_namespace" {
  source = "../modules/namespace"
  zone_name = local.zone_name
  region_name = local.region_name
  vpc_name = local.vpc_name
}

module "argocd-instance" {
  source = "../modules/argocd-instance"
  name = "argocd-1"
  namespace = module.supervisor_namespace.namespace
  depends_on = [ module.supervisor_namespace ]
}