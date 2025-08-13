# VKS Cluster

This example creates a VKS cluster and a supervisor namespace. 


## Usage

1. create a terraform.tfvars file with the below contents 

```
vcfa_refresh_token = "your-token"
vcfa_url = "https://your-vcf-url.com"
vcfa_org = "will-org"
vpc_name = "us-west-Default-VPC"
region_name = "us-west"
zone_name = "zone1"
```

2. run terraform, we need to do two applies due to the way the k8s provider works. we need the namespace to exist first to be able to initiate the provider. 

```bash
terraform init
terraform apply -target=module.supervisor_namespace
terraform plan
terraform apply
```