variable "region_name" {
  type        = string
}

variable "vpc_name" {
  type        = string
}

variable "zone_name" {
  type        = string
}

variable "name" {
  type = string
  default = "lab"
}

variable "storage_limit" {
  type = string
  default = "102400Mi"
}