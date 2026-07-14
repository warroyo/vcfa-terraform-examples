# 1. the policy template. this is an org scoped resource that wraps an OPA
# Gatekeeper ConstraintTemplate containing the Rego enforcement logic. only org
# admins can create templates. creating a template auto generates a
# ClusterPolicySchema of type custom-policy named "<template_name>:custom-policy".
resource "kubernetes_manifest" "policy_template" {
  manifest = {
    "apiVersion" = "policy.management.kubernetes.vmware.com/v1alpha1"
    "kind"       = "ClusterPolicyTemplate"
    "metadata" = {
      "name"      = var.template_name
      "namespace" = "@org"
    }
    "spec" = {
      "templateType" = "OPAGatekeeper"
      "objectKind"   = "ConstraintTemplate"
      # the embedded Gatekeeper ConstraintTemplate. its metadata.name must match
      # the ClusterPolicyTemplate metadata.name above.
      "object" = {
        "apiVersion" = "templates.gatekeeper.sh/v1"
        "kind"       = "ConstraintTemplate"
        "metadata" = {
          "name" = var.template_name
        }
        "spec" = {
          "crd" = {
            "spec" = {
              "names" = {
                "kind" = var.constraint_kind
              }
              "validation" = {
                "openAPIV3Schema" = {
                  "type"       = "object"
                  "properties" = var.parameters_schema
                }
              }
            }
          }
          "targets" = [
            {
              "target" = var.target
              "rego"   = "package ${var.template_name}\n\n${var.rego_rules}"
            }
          ]
        }
      }
    }
  }
}

# 2. the custom policy, referencing the schema generated from the template
# above and applied at the requested scope via the cluster-policy module.
module "policy" {
  source = "../cluster-policy"

  policy_scope               = var.policy_scope
  project_name               = var.project_name
  policy_name                = var.policy_name
  policy_schema_name         = "${var.template_name}:custom-policy"
  policy_input               = var.policy_input
  cluster_namespace_selector = var.cluster_namespace_selector
  cluster_name               = var.cluster_name
  supervisor_namespace_name  = var.supervisor_namespace_name

  # the schema is generated asynchronously after the template is created, so
  # make sure the template exists first. if the policy apply fails because the
  # schema is not yet available, re-run terraform apply.
  depends_on = [kubernetes_manifest.policy_template]
}
