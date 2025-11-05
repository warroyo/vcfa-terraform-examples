
variable "namespace" {
  type        = string
}

variable "argocd_namespace" {
  type        = string
  default = null
}

variable "sa_name" {
  type = string
  default = "argocd-manager"
  
}
variable "role_type" {
  type = string  
  default = "ClusterRole"
}

variable "role_name" {
  type = string
  default = "edit"
  
}