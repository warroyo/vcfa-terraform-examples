variable "template_name" {
  type        = string
  description = "Lowercase name for the ClusterPolicyTemplate/ConstraintTemplate. Also used as the Rego package name, so it must match the lowercase of constraint_kind (Gatekeeper requirement)"
}

variable "constraint_kind" {
  type        = string
  description = "The CRD kind Gatekeeper generates for this constraint, PascalCase, its lowercase form must equal template_name"
}

variable "parameters_schema" {
  type        = any
  description = "The openAPIV3Schema.properties object describing the parameters callers can pass in the ClusterPolicy input"
  default     = {}
}

variable "rego_rules" {
  type        = string
  description = "The Gatekeeper Rego violation rule bodies. The module wraps this with the `package <template_name>` header, so only supply the rule bodies"
}

variable "target" {
  type        = string
  description = "The Gatekeeper admission target the rules are enforced against"
  default     = "admission.k8s.gatekeeper.sh"
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

variable "project_name" {
  type        = string
  description = "The VCF Automation project to apply the policy to, used for project and cluster scoped policies"
  default     = "default-project"
}

variable "policy_name" {
  type        = string
  description = "The name of the custom ClusterPolicy created from the template"
}

variable "policy_input" {
  type        = any
  description = "Input values for the policy. The valid shape is defined by the openAPIV3Schema of the generated <template_name>:custom-policy schema, inspect it with `kubectl get clusterpolicyschema <template_name>:custom-policy -n @org -o yaml`"
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
