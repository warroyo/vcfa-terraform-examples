# Cluster Policy

This example creates a `ClusterPolicy` using the new VKS cluster management policy APIs introduced with VCF-A 9.1. These are kubernetes style APIs (`policy.management.kubernetes.vmware.com/v1alpha1`) that are served from the org level VCF-A kubernetes endpoint, so they can be managed with the terraform kubernetes provider using the org level kubeconfig from the `vcfa_kubeconfig` data source.

Policies can be applied at three levels of the hierarchy and are inherited down the tree:

* **org** - applies to every project and cluster in the org. uses the special `@org` namespace.
* **project** - applies to every cluster in the project. uses the project name as the namespace.
* **cluster** - applies to a single cluster. targets the cluster using `spec.selector.matchNames` with the cluster name and supervisor namespace name.

Every `ClusterPolicy` references a `ClusterPolicySchema` which defines the policy type (security, image registry, quota, mutation, custom) and the valid inputs for the policy. Some useful commands for discovering what is available, these can be run using the org level kubeconfig(this can be generated using the vcf cli):

```bash
# list all of the available policy schemas e.g. baseline:security-policy, restricted:security-policy
kubectl get clusterpolicyschemas

# view the input schema for a specific policy schema
kubectl get clusterpolicyschema baseline:security-policy -o yaml

# list applied policies and check their status
kubectl get clusterpolicies -A

# view policy violations and other insights
kubectl get clusterpolicyinsights -A
```

### Pre-requisites

* VCF-A 9.1+
* [VKS Cluster Management](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vcf-9-0-and-later/9-0/organization-management/managing-vks-clusters-with-vks-cluster-management/installation-and-enablement-of-vks-cluster-management.html) enabled
* Organization Administrator or Project Administrator role
* at least one VKS cluster being managed by VKS cluster management

## Usage

1. create a terraform.tfvars file with the below contents

```
vcfa_refresh_token = "your-token"
vcfa_url           = "https://your-vcf-url.com"
vcfa_org           = "your-org"

# scope to apply the policy at: org, project, or cluster
policy_scope = "project"
project_name = "default-project"

policy_name        = "baseline-security"
policy_schema_name = "baseline:security-policy"

# optional, inputs depend on the chosen schema. view the valid inputs with:
# kubectl get clusterpolicyschema <schema-name> -o yaml
# policy_input = {
#   enforcementAction = "deny"
# }

# optional, filter which namespaces in the cluster the policy applies to
# cluster_namespace_selector = {
#   matchLabels = {
#     env = "prod"
#   }
# }

# only needed when policy_scope = "cluster"
# cluster_name              = "lab-1"
# supervisor_namespace_name = "lab-xxxxx"
```

2. run terraform. unlike the namespace based examples in this repo, this only needs a single apply because the org level kubernetes endpoint already exists.

```bash
terraform init
terraform apply
```

## Notes

* when a policy is applied at the org or project level, read-only inherited `ClusterPolicy` resources will show up on every project/cluster below it, prefixed with `org:` or `prj:`. Deleting the policy created here removes the inherited copies.
* policies lower in the hierarchy can not relax the constraints of an inherited policy, only tighten them.
* most policy types (security, image registry, mutation, custom) are enforced with OPA Gatekeeper, which VKS cluster management installs on the cluster when the first policy is applied. quota policies use native kubernetes `ResourceQuota` objects.
