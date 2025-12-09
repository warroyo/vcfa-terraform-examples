variable "vcfa_refresh_token" {
  type        = string
  description = "The VCF Automation refresh token"
  sensitive   = true
}

variable "vault_url" {
  type        = string
  description = "The VCF Automation url"
}

variable "vault_token" {
  type        = string
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