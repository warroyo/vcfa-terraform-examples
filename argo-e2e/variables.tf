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