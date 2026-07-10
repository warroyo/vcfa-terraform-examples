variable "namespace" {
  type = string
}

variable "name" {
  type = string
}

variable "vmClass" {
  type = string
  default = "best-effort-small"
}

variable "storageClass" {
  type = string
  default = "vsan-default-storage-policy"
}

variable "cluster_class" {
  type = string
  default = "builtin-generic-v3.7.0"
}

variable "k8s_version" {
  type = string
  default = "v1.35.2+vmware.1"
}

variable "worker_replicas" {
  type = number
  default = 1
}

variable "cni_name" {
  type    = string
  default = "antrea"
}

variable "cni_namespace" {
  type    = string
  default = "vmware-system-vks-public"
}
