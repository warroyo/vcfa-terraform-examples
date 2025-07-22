# Namespace with ArgoCD integration

This example creates a supervisor namespace with an instance of [ArgoCD](https://blogs.vmware.com/cloud-foundation/2025/07/11/gitops-for-vcf-broadcom-argo-cd-operator-now-available/) deployed into it. This will also register the namespace back to ArgoCD, this allows for managining resources in the namespace using ArgoCD.  Finally it will deploy a basic ArgoCD app that creates a VKS cluster. 

### Pre-requisites 

* the [ArgoCD supervisor service](https://techdocs.broadcom.com/us/en/vmware-cis/vcf/vsphere-supervisor-services-and-standalone-components/latest/using-supervisor-services/using-argo-cd-service.html) deployed

## Usage

1. create a terraform.tfvars file with the below contents 

```
vcfa_refresh_token = "your-token"
vcfa_url = "https://your-vcf-url.com"
vcfa_org = "your-org"
zone_name = "zone name"
region_name = "region name"
vpc_name = "vpc name"
```


3. run terraform, we need to do two applies due to the way the k8s provider works. we need the namespace to exist first to be able to initiate the provider. 

```bash
terraform init
terraform apply -target=module.supervisor_namespace
terraform plan
terraform apply
```