module "require_resource_limits" {
  source = "../modules/cluster-policy-custom"

  # the ConstraintTemplate name must be the lowercase of constraint_kind
  template_name   = "requireresourcelimits"
  constraint_kind = "RequireResourceLimits"

  parameters_schema = {
    limits = {
      type        = "array"
      description = "the resource limit keys that must be set on every container, e.g. cpu, memory"
      items = {
        type = "string"
      }
    }
  }

  rego_rules = <<-REGO
    violation[{"msg": msg}] {
      container := input.review.object.spec.containers[_]
      limit := input.parameters.limits[_]
      not container.resources.limits[limit]
      msg := sprintf("container %q is missing required resource limit %q", [container.name, limit])
    }
  REGO

  policy_scope = "project"
  project_name = var.project_name
  policy_name  = var.policy_name

  policy_input = {
    parameters = {
      limits = var.required_limits
    }
    targetKubernetesResources = var.target_resources
    enforcementAction         = var.enforcement_action
  }
}
