locals {
  # OPA Gatekeeper requires the ConstraintTemplate name to be the lowercase of
  # its CRD kind, so keep these two in sync if you rename the template. The
  # ClusterPolicyTemplate name must also match the embedded object name.
  template_name   = "requireteamlabels"
  constraint_kind = "RequireTeamLabels"

  # creating a ClusterPolicyTemplate auto generates a ClusterPolicySchema of
  # type custom-policy named "<template-name>:custom-policy". the ClusterPolicy
  # below references that generated schema.
  schema_name = "${local.template_name}:custom-policy"
}

# 1. the policy template. this is an org scoped resource that wraps an OPA
# Gatekeeper ConstraintTemplate containing the Rego enforcement logic. only org
# admins can create templates. this require-labels logic mirrors the built-in
# vksm-require-labels template but is defined here to demonstrate managing a
# custom template end to end.
resource "kubernetes_manifest" "policy_template" {
  manifest = {
    "apiVersion" = "policy.management.kubernetes.vmware.com/v1alpha1"
    "kind"       = "ClusterPolicyTemplate"
    "metadata" = {
      "name"      = local.template_name
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
          "name" = local.template_name
        }
        "spec" = {
          "crd" = {
            "spec" = {
              "names" = {
                "kind" = local.constraint_kind
              }
              # defines the parameters callers can pass in the ClusterPolicy input
              "validation" = {
                "openAPIV3Schema" = {
                  "type" = "object"
                  "properties" = {
                    "labels" = {
                      "type"        = "array"
                      "description" = "the label keys that must be present on the resource"
                      "items" = {
                        "type" = "string"
                      }
                    }
                  }
                }
              }
            }
          }
          "targets" = [
            {
              "target" = "admission.k8s.gatekeeper.sh"
              "rego"   = <<-REGO
                package ${local.template_name}

                violation[{"msg": msg, "details": {"missing_labels": missing}}] {
                  provided := {label | input.review.object.metadata.labels[label]}
                  required := {label | label := input.parameters.labels[_]}
                  missing := required - provided
                  count(missing) > 0
                  msg := sprintf("missing required labels: %v", [missing])
                }
              REGO
            }
          ]
        }
      }
    }
  }
}

# 2. the custom policy, applied at the project level. it references the schema
# generated from the template above and passes the parameters, target resources
# and enforcement action as input. the input shape is defined by the generated
# ClusterPolicySchema, inspect it before applying with:
#   kubectl get clusterpolicyschema requireteamlabels:custom-policy -n @org -o yaml
resource "kubernetes_manifest" "custom_policy" {
  manifest = {
    "apiVersion" = "policy.management.kubernetes.vmware.com/v1alpha1"
    "kind"       = "ClusterPolicy"
    "metadata" = {
      "name"      = var.policy_name
      "namespace" = var.project_name
    }
    "spec" = merge(
      {
        "clusterPolicySchemaRef" = {
          "name"      = local.schema_name
          "namespace" = "@org"
        }
        "input" = {
          "parameters" = {
            "labels" = var.required_labels
          }
          "match" = {
            "kinds" = var.target_resources
          }
          "enforcementAction" = var.enforcement_action
        }
      },
      var.cluster_namespace_selector != null ? { "clusterNamespaceSelector" = var.cluster_namespace_selector } : {}
    )
  }

  # the schema is generated asynchronously after the template is created, so make
  # sure the template exists first. if the policy apply fails because the schema
  # is not yet available, re-run terraform apply.
  depends_on = [kubernetes_manifest.policy_template]
}
