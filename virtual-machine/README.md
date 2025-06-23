# VKS Cluster

This example creates a VKS cluster and a supervisor namespace. 


## Usage

1. create a terraform.tfvars file with the below contents 

```
vcfa_refresh_token = "your-token"
vcfa_url = "https://your-vcf-url.com"
```

2. update the local vars in `main.tf` to match your environment

3. run terraform

```bash
terraform init
terraform plan
terraform apply
```