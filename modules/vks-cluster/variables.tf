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
  default = "builtin-generic-v3.4.0"
}

variable "k8s_version" {
  type = string
  default = "v1.32.0+vmware.6-fips"
}