# End to End example 

This example creates an environment from scratch that uses ArgoCD to deploy an app. This will create the following:

* Supervisor Namespace
* ArgoCD instance
* VKS Cluster
* Register the namespace to ArgoCD
* Register the cluster to ArgoCD
* Deploy an ecommerce app


### Pre-requisites 

* The [ArgoCD supervisor service](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vsphere-supervisor-services-and-standalone-components/latest/using-supervisor-services/using-argo-cd-service.html) deployed


## Usage

1. create a terraform.tfvars file with the below contents 

```
vcfa_refresh_token = "your-token"
vcfa_url = "https://your-vcf-url.com"
vcfa_org = "your-org"
zone_name = "zone name"
region_name = "region name"
vpc_name = "vpc name"
namespace = "namespace name"
cluster = "cluster name
```


3. run terraform, we need to do two applies due to the way the k8s provider works. we need the namespace to exist first to be able to initiate the provider. 

```bash
terraform init
terraform apply -target=module.supervisor_namespace
terraform plan
terraform apply
```