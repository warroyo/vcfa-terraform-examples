variable "cluster-name" {
  type        = string
}

variable "cluster-host" {
  type        = string
}

variable "cluster-ca" {
  description = "base64 encoded cluster ca"
  type        = string
}


variable "supervisor-namespace" {
  type        = string
}