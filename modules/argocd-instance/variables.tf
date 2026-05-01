variable "name" {
  type        = string
}

variable "namespace" {
  type        = string
}

variable "password" {
  type = string
  sensitive = true
  default = ""
}

variable "role_type" {
  type = string  
  default = "ClusterRole"
}

variable "role_name" {
  type = string
  default = "edit"
}

variable "argocd_version" {
  type    = string
  default = "3.0.19+vmware.1-vks.1"
}