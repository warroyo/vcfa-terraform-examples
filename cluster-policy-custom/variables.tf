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
  description = "The VCF Automation project to apply the custom policy to"
  default     = "default-project"
}

variable "policy_name" {
  type        = string
  description = "The name of the custom ClusterPolicy created in the project"
  default     = "require-team-labels"
}

variable "required_labels" {
  type        = list(string)
  description = "The label keys that the policy requires on the targeted resources"
  default     = ["team", "cost-center"]
}

variable "target_resources" {
  type = list(object({
    apiGroups = list(string)
    kinds     = list(string)
  }))
  description = "The kubernetes resource kinds/apiGroups the policy is enforced on"
  default = [
    {
      apiGroups = [""]
      kinds     = ["Namespace"]
    }
  ]
}

variable "enforcement_action" {
  type        = string
  description = "How the policy is enforced, one of: deny, dryrun, warn"
  default     = "deny"

  validation {
    condition     = contains(["deny", "dryrun", "warn"], var.enforcement_action)
    error_message = "enforcement_action must be one of: deny, dryrun, warn"
  }
}

variable "cluster_namespace_selector" {
  type        = any
  description = "Optional label based selector to filter which namespaces in the cluster the policy applies to. e.g. { matchLabels = { env = \"prod\" } }"
  default     = null
}
