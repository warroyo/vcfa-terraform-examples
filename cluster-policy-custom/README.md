# Custom Cluster Policy

This example manages a **custom** VKS cluster management policy end to end and applies it to a project, using the 9.1 policy APIs (`policy.management.kubernetes.vmware.com/v1alpha1`). For the basic (built-in schema) version see [cluster-policy](../cluster-policy/).

Custom policies are enforced by OPA Gatekeeper. Managing one has two parts:

1. **`ClusterPolicyTemplate`** - an org scoped resource that wraps an OPA Gatekeeper `ConstraintTemplate` containing the Rego enforcement logic. Only org admins can create templates. Creating a template automatically generates a matching **`ClusterPolicySchema`** named `<template-name>:custom-policy`.
2. **`ClusterPolicy`** - references the generated schema and is applied to a project (`metadata.namespace = <project-name>`). It passes the parameters, target resources, and enforcement action as `input`.

This example defines a `requireteamlabels` template that requires a set of labels to be present on targeted resources (a custom version of the built-in `vksm-require-labels` template), then creates a policy from it in a project requiring `team` and `cost-center` labels on all namespaces.

Because the policy is applied at the project level, a read-only inherited copy (prefixed with `prj:`) shows up on every cluster in the project, and the constraint is enforced on those clusters by Gatekeeper.

### Pre-requisites

* VCF-A 9.1+
* [VKS Cluster Management](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/organization-management/managing-vks-clusters-with-vks-cluster-management/installation-and-enablement-of-vks-cluster-management.html) enabled
* Organization Administrator role (required to create the policy template)
* at least one VKS cluster in the target project being managed by VKS cluster management

## Usage

1. create a terraform.tfvars file with the below contents

```
vcfa_refresh_token = "your-token"
vcfa_url           = "https://your-vcf-url.com"
vcfa_org           = "your-org"

project_name = "default-project"
policy_name  = "require-team-labels"

# the label keys required on the targeted resources
required_labels = ["team", "cost-center"]

# the resources the policy is enforced on
target_resources = [
  {
    apiGroups = [""]
    kinds     = ["Namespace"]
  }
]

# deny | dryrun | warn
enforcement_action = "deny"

# optional, filter which namespaces in the cluster the policy applies to
# cluster_namespace_selector = {
#   matchLabels = {
#     env = "prod"
#   }
# }
```

2. run terraform.

```bash
terraform init
terraform apply
```

The template is created first, then the policy. The schema is generated asynchronously from the template, so if the policy apply fails because the schema is not yet available, just re-run `terraform apply`.

## Verifying the input schema

The `spec.input` of the `ClusterPolicy` must match the `openAPIV3Schema` of the generated `ClusterPolicySchema`. The `input` in this example (`parameters`, `match`, `enforcementAction`) follows the Gatekeeper constraint model, but you should confirm the exact shape against your environment before applying. Using the org level kubeconfig (generate it with the vcf cli):

```bash
# confirm the schema was generated from the template
kubectl get clusterpolicyschemas -n @org | grep requireteamlabels

# view the input schema the policy must satisfy
kubectl get clusterpolicyschema requireteamlabels:custom-policy -n @org -o yaml

# list the built-in templates you can build custom policies from without
# defining your own, e.g. vksm-require-labels, vksm-block-nodeport-service
kubectl get clusterpolicytemplates -n @org

# check the applied policy and any violations
kubectl get clusterpolicies -n <project-name>
kubectl get clusterpolicyinsights -A
```

If your generated schema expects a different input structure, adjust the `input` block in `main.tf` accordingly.

## Notes

* the ConstraintTemplate name must be the lowercase of its CRD `kind` (Gatekeeper requirement), and the `ClusterPolicyTemplate` name must match the embedded ConstraintTemplate name. The `template_name`/`constraint_kind` locals in `main.tf` keep these consistent.
* built-in templates cannot be edited or deleted. This example creates its own template so it can be managed fully by terraform.
* a policy lower in the hierarchy can not relax the constraints of an inherited policy, only tighten them.
