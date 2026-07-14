variable "vcfa_refresh_token" {
  type        = string
  description = "The VCF Automation refresh token"
  sensitive   = true
}

variable "vcfa_url" {
  type        = string
  description = "The VCF Automation url"
}

variable "vcfa_org" {
  type        = string
  description = "The VCF Automation org"
}

variable "project_name" {
  type        = string
  description = "The VCF Automation project to apply the baseline security policy to"
  default     = "default-project"
}

variable "policy_name" {
  type        = string
  description = "The name of the cluster policy"
  default     = "baseline-security"
}

variable "policy_input" {
  type        = any
  description = "Input values for the policy, the valid inputs are defined in the openAPIV3Schema of the baseline:security-policy schema"
  default = {
    enforcementAction = "dryrun"
  }
}
