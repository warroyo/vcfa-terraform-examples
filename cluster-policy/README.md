# Cluster Policy

This example applies the built-in `baseline:security-policy` `ClusterPolicy` to a project, using the [`cluster-policy`](../modules/cluster-policy/) module. This example just wires up the `vcfa`/`kubernetes` providers and calls that module with a fixed `policy_scope = "project"` and `policy_schema_name = "baseline:security-policy"`.

For org/cluster scoped policies, other built-in schemas, or the full set of module inputs, see the [module README](../modules/cluster-policy/).

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

project_name = "default-project"
policy_name  = "baseline-security"

# optional, valid inputs depend on the baseline:security-policy schema. view them with:
# kubectl get clusterpolicyschema baseline:security-policy -n @org -o yaml
# defaults to dryrun, switch to deny once you've reviewed the violations
# policy_input = {
#   enforcementAction = "dryrun"
# }
```

2. run terraform. unlike the namespace based examples in this repo, this only needs a single apply because the org level kubernetes endpoint already exists.

```bash
terraform init
terraform apply
```
