# cluster-policy-custom module

Manages a **custom** VKS cluster management policy end to end, using the 9.1 policy APIs (`policy.management.kubernetes.vmware.com/v1alpha1`). For built-in schema policies (e.g. `baseline:security-policy`) use the [`cluster-policy`](../cluster-policy/) module instead, this module builds on top of it for step 2 below.

Custom policies are enforced by OPA Gatekeeper. Managing one has two parts:

1. **`ClusterPolicyTemplate`** - an org scoped resource that wraps an OPA Gatekeeper `ConstraintTemplate` containing the Rego enforcement logic. Only org admins can create templates. Creating a template automatically generates a matching **`ClusterPolicySchema`** named `<template_name>:custom-policy`.
2. **`ClusterPolicy`** - references the generated schema and is applied at the requested scope (org/project/cluster, see the [`cluster-policy`](../cluster-policy/) module docs for the scoping rules). It passes the parameters, target resources, and enforcement action as `input`.

This module does not configure providers, the caller is expected to do that (see [`cluster-policy-custom`](../../cluster-policy-custom/) for an example).

## Usage

```hcl
module "require_resource_limits" {
  source = "../modules/cluster-policy-custom"

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
  project_name = "default-project"
  policy_name  = "require-resource-limits"

  policy_input = {
    parameters = {
      limits = ["cpu", "memory"]
    }
    targetKubernetesResources = [
      {
        apiGroups = [""]
        kinds     = ["Pod"]
      }
    ]
    enforcementAction = "dryrun"
  }
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `template_name` | Lowercase name for the `ClusterPolicyTemplate`/`ConstraintTemplate`. Also used as the Rego package name, so it must match the lowercase of `constraint_kind` (Gatekeeper requirement) | - |
| `constraint_kind` | The CRD kind Gatekeeper generates for this constraint, PascalCase, its lowercase form must equal `template_name` | - |
| `parameters_schema` | The `openAPIV3Schema.properties` object describing the parameters callers can pass in the `ClusterPolicy` input | `{}` |
| `rego_rules` | The Gatekeeper Rego violation rule bodies. The module wraps this with the `package <template_name>` header, so only supply the rule bodies | - |
| `target` | The Gatekeeper admission target the rules are enforced against | `"admission.k8s.gatekeeper.sh"` |
| `policy_scope` | The scope to apply the policy at, one of: `org`, `project`, `cluster` | `"project"` |
| `project_name` | The VCF Automation project to apply the policy to, used for project and cluster scoped policies | `"default-project"` |
| `policy_name` | The name of the custom `ClusterPolicy` created from the template | - |
| `policy_input` | Input values for the policy. The valid shape is defined by the `openAPIV3Schema` of the generated `<template_name>:custom-policy` schema | - |
| `cluster_namespace_selector` | Optional label based selector to filter which namespaces in the cluster the policy applies to, e.g. `{ matchLabels = { env = "prod" } }` | `null` |
| `cluster_name` | The name of the VKS cluster to apply the policy to, only used when `policy_scope` is `cluster` | `null` |
| `supervisor_namespace_name` | The supervisor namespace the VKS cluster is in, only used when `policy_scope` is `cluster` | `null` |

## Verifying the input schema

The `policy_input` must match the `openAPIV3Schema` of the generated `ClusterPolicySchema`. Using the org level kubeconfig (generate it with the vcf cli):

```bash
# confirm the schema was generated from the template
kubectl get clusterpolicyschemas -n @org | grep <template_name>

# view the input schema the policy must satisfy
kubectl get clusterpolicyschema <template_name>:custom-policy -n @org -o yaml

# list the built-in templates you can build custom policies from without
# defining your own, e.g. vksm-require-labels, vksm-block-nodeport-service
kubectl get clusterpolicytemplates -n @org

# check the applied policy and any violations
kubectl get clusterpolicies -A
kubectl get clusterpolicyinsights -A
```

If the generated schema expects a different input structure than expected, adjust `policy_input` accordingly.

## Notes

* the ConstraintTemplate name must be the lowercase of its CRD `kind` (Gatekeeper requirement), which is why `template_name` and `constraint_kind` must agree.
* built-in templates cannot be edited or deleted. Defining your own template here means it can be managed fully by terraform.
* the schema is generated asynchronously after the template is created. If the policy apply fails because the schema is not yet available, re-run `terraform apply`.
* a policy lower in the hierarchy can not relax the constraints of an inherited policy, only tighten them.
