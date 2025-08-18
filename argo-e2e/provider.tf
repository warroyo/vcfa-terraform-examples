terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    vcfa = {
      source = "vmware/vcfa"
    }
    argocd = {
      source = "argoproj-labs/argocd"
      version = "7.10.1"
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
}

provider "kubernetes" {
  host     = data.vcfa_kubeconfig.kubeconfig.host
  insecure = data.vcfa_kubeconfig.kubeconfig.insecure_skip_tls_verify
  token    = data.vcfa_kubeconfig.kubeconfig.token
}

provider "argocd" {
  server_addr = module.argocd-instance.server_ip
  username    = "admin"
  password    = module.argocd-instance.admin_password
  insecure = true
}