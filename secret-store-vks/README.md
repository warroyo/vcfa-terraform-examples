# Example of integrating a VKS cluster with the secret store service integration

This example provides an end to end setup for deploying a cluster and integrating it with the secret store service and consumign a secret. This example will do the following 

* Create a VKS cluster
* Create the necesary auth backend and roles in Secret Store for the VKS cluster
* Attach Cluster to ArgoCD
* Create a secret in the namespace using the secret store service
* Deploy a argocd app that deploys vault injector and connects to secret store
* deploy argocd app that deploys a sample app that consumes a secret


### Pre-requisites 

* The [ArgoCD supervisor service](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vsphere-supervisor-services-and-standalone-components/latest/using-supervisor-services/using-argo-cd-service.html) deployed
* The [secret store service]() deployed
* Existing Namespace
* Existing ArgoCD instance in the namespace


## Usage

1. create a terraform.tfvars file with the below contents 

```
vcfa_refresh_token = "your-token"
vcfa_url = "https://your-vcf-url.com"
vcfa_org = "your-org"
namespace = "namespace name"
cluster = "cluster name
vault_token = ""
vault_url = ""
```


3. run terraform

```bash
terraform init
terraform plan
terraform apply
```