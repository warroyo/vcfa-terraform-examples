locals {
  # org scoped policies go in the special "@org" namespace, project and cluster
  # scoped policies go in the project namespace
  policy_namespace = var.policy_scope == "org" ? "@org" : var.project_name

  # cluster scoped policies require a fully qualified name in the format
  # <policy-name>:cluster:<cluster-name>:supervisor-namespace:<svns-name>
  policy_name = var.policy_scope == "cluster" ? "${var.policy_name}:cluster:${var.cluster_name}:supervisor-namespace:${var.supervisor_namespace_name}" : var.policy_name

  policy_spec = merge(
    {
      clusterPolicySchemaRef = {
        name      = var.policy_schema_name
        namespace = "@org"
      }
    },
    # cluster scoped policies target the cluster with the selector
    var.policy_scope == "cluster" ? {
      selector = {
        matchNames = [var.cluster_name, var.supervisor_namespace_name]
      }
    } : {},
    var.policy_input != null ? { input = var.policy_input } : {},
    var.cluster_namespace_selector != null ? { clusterNamespaceSelector = var.cluster_namespace_selector } : {}
  )
}

resource "kubernetes_manifest" "cluster_policy" {
  lifecycle {
    precondition {
      condition     = var.policy_scope != "cluster" || (var.cluster_name != null && var.supervisor_namespace_name != null)
      error_message = "cluster_name and supervisor_namespace_name are required when policy_scope is cluster"
    }
  }

  manifest = {
    "apiVersion" = "policy.management.kubernetes.vmware.com/v1alpha1"
    "kind"       = "ClusterPolicy"
    "metadata" = {
      "name"      = local.policy_name
      "namespace" = local.policy_namespace
    }
    "spec" = local.policy_spec
  }
}
