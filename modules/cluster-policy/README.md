# cluster-policy module

Creates a `ClusterPolicy` using the VKS cluster management policy APIs introduced with VCF-A 9.1. These are kubernetes style APIs (`policy.management.kubernetes.vmware.com/v1alpha1`) that are served from the org level VCF-A kubernetes endpoint, so they are managed with the terraform kubernetes provider using the org level kubeconfig from the `vcfa_kubeconfig` data source. This module does not configure providers, the caller is expected to do that (see [`cluster-policy`](../../cluster-policy/) for an example).

Policies can be applied at three levels of the hierarchy and are inherited down the tree:

* **org** - applies to every project and cluster in the org. uses the special `@org` namespace.
* **project** - applies to every cluster in the project. uses the project name as the namespace.
* **cluster** - applies to a single cluster. targets the cluster using `spec.selector.matchNames` with the cluster name and supervisor namespace name.

Every `ClusterPolicy` references a `ClusterPolicySchema` which defines the policy type (security, image registry, quota, mutation, custom) and the valid inputs for the policy. Some useful commands for discovering what is available, these can be run using the org level kubeconfig (this can be generated using the vcf cli):

```bash
# list all of the available policy schemas e.g. baseline:security-policy, restricted:security-policy
kubectl get clusterpolicyschemas -n @org

# view the input schema for a specific policy schema
kubectl get clusterpolicyschema baseline:security-policy -n @org -o yaml

# list applied policies and check their status
kubectl get clusterpolicies -A

# view policy violations and other insights
kubectl get clusterpolicyinsights -A
```

## Usage

```hcl
module "cluster_policy" {
  source = "../modules/cluster-policy"

  policy_scope       = "cluster"
  policy_name        = "baseline-security"
  policy_schema_name = "baseline:security-policy"

  cluster_name               = "lab-1"
  supervisor_namespace_name  = "lab-xxxxx"

  policy_input = {
    enforcementAction = "deny"
  }

  cluster_namespace_selector = {
    matchLabels = {
      env = "prod"
    }
  }
}
```

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `project_name` | The VCF Automation project to apply the policy to, used for project and cluster scoped policies | `"default-project"` |
| `policy_scope` | The scope to apply the policy at, one of: `org`, `project`, `cluster` | `"project"` |
| `policy_name` | The name of the cluster policy | `"baseline-security"` |
| `policy_schema_name` | The name of the `ClusterPolicySchema` to use. list available schemas with `kubectl get clusterpolicyschemas` | `"baseline:security-policy"` |
| `policy_input` | Input values for the policy, the valid inputs are defined in the `openAPIV3Schema` of the chosen `ClusterPolicySchema` | `null` |
| `cluster_namespace_selector` | Optional label based selector to filter which namespaces in the cluster the policy applies to, e.g. `{ matchLabels = { env = "prod" } }` | `null` |
| `cluster_name` | The name of the VKS cluster to apply the policy to, only used when `policy_scope` is `cluster` | `null` |
| `supervisor_namespace_name` | The supervisor namespace the VKS cluster is in, only used when `policy_scope` is `cluster` | `null` |

## Notes

* when a policy is applied at the org or project level, read-only inherited `ClusterPolicy` resources will show up on every project/cluster below it, prefixed with `org:` or `prj:`. Deleting the policy created here removes the inherited copies.
* policies lower in the hierarchy can not relax the constraints of an inherited policy, only tighten them.
* most policy types (security, image registry, mutation, custom) are enforced with OPA Gatekeeper, which VKS cluster management installs on the cluster when the first policy is applied. quota policies use native kubernetes `ResourceQuota` objects.
