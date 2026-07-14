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
  description = "The VCF Automation project to apply the policy to, used for project and cluster scoped policies"
  default     = "default-project"
}

variable "policy_scope" {
  type        = string
  description = "The scope to apply the policy at, one of: org, project, cluster"
  default     = "project"

  validation {
    condition     = contains(["org", "project", "cluster"], var.policy_scope)
    error_message = "policy_scope must be one of: org, project, cluster"
  }
}

variable "policy_name" {
  type        = string
  description = "The name of the cluster policy"
  default     = "baseline-security"
}

variable "policy_schema_name" {
  type        = string
  description = "The name of the ClusterPolicySchema to use. list available schemas with `kubectl get clusterpolicyschemas`"
  default     = "baseline:security-policy"
}

variable "policy_input" {
  type        = any
  description = "Input values for the policy, the valid inputs are defined in the openAPIV3Schema of the chosen ClusterPolicySchema"
  default     = null
}

variable "cluster_namespace_selector" {
  type        = any
  description = "Optional label based selector to filter which namespaces in the cluster the policy applies to. e.g. { matchLabels = { env = \"prod\" } }"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "The name of the VKS cluster to apply the policy to, only used when policy_scope is cluster"
  default     = null
}

variable "supervisor_namespace_name" {
  type        = string
  description = "The supervisor namespace the VKS cluster is in, only used when policy_scope is cluster"
  default     = null
}
