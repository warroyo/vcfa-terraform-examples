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

variable "token_auth" {
  type = bool
  default = false
}

variable "labels" {
  default = {
  }
  type = map(string)
}