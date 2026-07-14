# Custom Cluster Policy

This example defines a `requireresourcelimits` custom policy template that requires every container in a targeted resource to declare specific resource limits (`cpu`, `memory` by default), then applies it to a project. It uses the [`cluster-policy-custom`](../modules/cluster-policy-custom/) module for the template + policy wiring. For a different custom policy demo (requiring labels) or full details on how custom policies work, see the [module README](../modules/cluster-policy-custom/).

Because the policy is applied at the project level, a read-only inherited copy (prefixed with `prj:`) shows up on every cluster in the project, and the constraint is enforced there by Gatekeeper.

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
policy_name  = "require-resource-limits"

# the resource limit keys required on every container
required_limits = ["cpu", "memory"]

# the resources the policy is enforced on
target_resources = [
  {
    apiGroups = [""]
    kinds     = ["Pod"]
  }
]

# deny | dryrun | warn, defaults to dryrun so you can review violations first
enforcement_action = "dryrun"
```

2. run terraform.

```bash
terraform init
terraform apply
```

The template is created first, then the policy. The schema is generated asynchronously from the template, so if the policy apply fails because the schema is not yet available, just re-run `terraform apply`.
