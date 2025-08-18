variable "cluster_name" {
  type        = string
}

variable "namespace" {
  type        = string
}

variable "kubeconfig" {
  type = string
  default = ""
  description = "yaml kubeconfig"
}