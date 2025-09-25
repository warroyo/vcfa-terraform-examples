locals {
  path = var.cluster-name
}
resource "vault_auth_backend" "vks-cluster" {
  type = "kubernetes"
  path = local.path

  tune {
    max_lease_ttl      = "90000s"
    listing_visibility = "unauth"
  }
}

resource "vault_kubernetes_auth_backend_config" "config" {
  backend                = vault_auth_backend.vks-cluster.path
  kubernetes_host        = var.cluster-host
  kubernetes_ca_cert     = base64decode(var.cluster-ca)
  disable_local_ca_jwt      = true
}

## this takes an approach of giving the cluster access to all namespace level secrets, this role is automatically created by secret store service
resource "vault_kubernetes_auth_backend_role" "cluster-wide" {
  backend                          = vault_auth_backend.vks-cluster.path
  role_name                        = "cluster-wide"
  bound_service_account_names      = ["*"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 3600
  token_policies                   = ["default", var.supervisor-namespace]
}