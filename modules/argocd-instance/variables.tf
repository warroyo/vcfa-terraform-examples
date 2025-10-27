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