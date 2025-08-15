# Cluster registered with ArgoCD

This example creates cluster in  a supervisor namespace that already has  [ArgoCD](https://blogs.vmware.com/cloud-foundation/2025/07/11/gitops-for-vcf-broadcom-argo-cd-operator-now-available/) deployed into it. Thsi will also register the cluster with ArgoCD so that apps can be deployed into it.


### Pre-requisites 

* The [ArgoCD supervisor service](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vsphere-supervisor-services-and-standalone-components/latest/using-supervisor-services/using-argo-cd-service.html) deployed

* An instance of ArgoCD has been deployed in a namespace, see the [argocd example](../argocd/)

## Usage

1. create a terraform.tfvars file with the below contents 

```
vcfa_refresh_token = "your-token"
vcfa_url = "https://your-vcf-url.com"
vcfa_org = "your-org"
zone_name = "zone name"
region_name = "region name"
vpc_name = "vpc name"
namespace = "existing namespace with argocd"
```


3. run terraform, we need to do two applies due to the way the k8s provider works. we need the namespace to exist first to be able to initiate the provider. 

```bash
terraform init
terraform apply -target=module.supervisor_namespace
terraform plan
terraform apply
```