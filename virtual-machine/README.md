# Virtual machine

This example creates Supervisor namespace, content library, uploads an ova to the library, creates a secret that holds the user's password Virtual machine, and  load balancer to connect to the VM over ssh. 


## Usage

1. create a terraform.tfvars file with the below contents 

```
vcfa_refresh_token = "your-token"
vcfa_url = "https://your-vcf-url.com"
vm_user_password = "VMware123!"
```

2. update the local vars in `main.tf` to match your environment

3. run terraform, we need to do two applies due to the way the k8s provider works. we need the namespace to exist first to be able to initiate the provider. 

```bash
terraform init
terraform apply -target=module.supervisor_namespace
terraform plan
terraform apply
```