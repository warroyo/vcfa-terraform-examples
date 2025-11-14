# End to End example 

This example creates an environment from scratch that uses ArgoCD to deploy an app. This will create the following:

* Supervisor Namespace
* ArgoCD instance
* Bootstrap Application Set for the namespace
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
argo_password = "somepasswd" # optional if you want to set a new default password
```



3. run terraform, we need to do two applies due to the way the k8s provider works. we need the namespace to exist first to be able to initiate the provider. 

```bash
terraform init
terraform apply -target=module.supervisor_namespace # only need to do this the first time
terraform plan
terraform apply
```


## Istio usage

you can optionally enable istio to be used along with exnternal DNS. To do that ensure you have a large cluster type at a minimum. the following vars need to be set as well.

```
bootstrap_revision = "main"
music_store_revision = "istio-support"
```