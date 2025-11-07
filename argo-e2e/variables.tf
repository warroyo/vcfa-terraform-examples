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
  default = "builtin-generic-v3.5.0"
}

variable "k8s_version" {
  type = string
  default = "v1.34.1+vmware.1"
}
variable "argo_password" {
  type = string
  sensitive = true
  default = ""
}

variable "bootstrap_revision" {
  type = string
  default = "1.0.0"
}

variable "music_store_revision" {
  type = string
  default = "main"
}