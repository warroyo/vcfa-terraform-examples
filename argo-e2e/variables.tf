variable "vcfa_refresh_token" {
  type        = string
  description = "The VCF Automation refresh token"
  sensitive   = true
}

variable "vcfa_url" {
  type        = string
  description = "The VCF Automation url"
}

variable "vcfa_org" {
  type        = string
  description = "The VCF Automation org"
}

variable "namespace" {
  type        = string
}

variable "cluster" {
  type        = string
}

variable "region_name" {
  type        = string
}

variable "vpc_name" {
  type        = string
}

variable "zone_name" {
  type        = string
}

variable "ns_storage_limit" {
  type = string
  default = "102400Mi"
}

variable "vm_class" {
  type = string
  default = "best-effort-large"
}

variable "cluster_class" {
  type = string
  default = "builtin-generic-v3.7.0"
}

variable "k8s_version" {
  type = string
  default = "v1.35.2+vmware.1"
}
variable "argo_password" {
  type = string
  sensitive = true
  default = ""
}

variable "bootstrap_revision" {
  type = string
  default = "2.0.1"
}

variable "music_store_revision" {
  type = string
  default = "main"
}

variable "music_store_repo" {
  type = string
  default = "https://github.com/NiranEC77/metal-music-store"
}

variable "ns_class" {
  type = string
  default = "small"
}

variable "dns_domain" {
  type = string
  default = "apps.vcf.lab"
  description = "domain that will be used for external dns"
}

variable "bootstrap_path" {
  type = string
  default = "./cluster-bootstrap/basic"
}

variable "storage_class_name" {
  type    = string
  default = "vSAN Default Storage Policy"
}

variable "argocd_version" {
  type    = string
  default = "3.0.19+vmware.1-vks.1"
}

variable "vks_storage_class" {
  type    = string
  default = "vsan-default-storage-policy"
}
