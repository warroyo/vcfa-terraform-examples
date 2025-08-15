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