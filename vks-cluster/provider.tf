terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    vcfa = {
      source = "vmware/vcfa"
    }

  }
}

provider "vcfa" {
  url                  = var.vcfa_url
  allow_unverified_ssl = true
  org                  = var.vcfa_org
  auth_type            = "api_token"
  api_token            = var.vcfa_refresh_token
}

data "vcfa_kubeconfig" "kubeconfig" {
  project_name              = "default-project"
  supervisor_namespace_name = module.supervisor_namespace.namespace
  depends_on = [ module.supervisor_namespace ]
}

provider "kubernetes" {
  host     = data.vcfa_kubeconfig.kubeconfig.host
  insecure = data.vcfa_kubeconfig.kubeconfig.insecure_skip_tls_verify
  token    = data.vcfa_kubeconfig.kubeconfig.token
}
