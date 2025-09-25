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

