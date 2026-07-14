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

# org level kubeconfig, no project or supervisor namespace is needed since the
# cluster policy APIs are served from the org level VCF-A kubernetes endpoint
data "vcfa_kubeconfig" "org" {}

provider "kubernetes" {
  host     = data.vcfa_kubeconfig.org.host
  insecure = data.vcfa_kubeconfig.org.insecure_skip_tls_verify
  token    = data.vcfa_kubeconfig.org.token
}
