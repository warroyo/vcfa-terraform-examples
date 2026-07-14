module "cluster_policy" {
  source = "../modules/cluster-policy"

  project_name       = var.project_name
  policy_scope       = "project"
  policy_name        = var.policy_name
  policy_schema_name = "baseline:security-policy"
  policy_input       = var.policy_input
}
