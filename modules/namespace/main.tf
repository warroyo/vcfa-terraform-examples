resource "vcfa_supervisor_namespace" "supervisor_namespace" {
  name_prefix  = "lab"
  project_name = "default-project"
  class_name   = "small"
  description  = "Supervisor Namespace with prefix [lab] created by Terraform"
  region_name  = var.region_name
  vpc_name     = var.vpc_name

  storage_classes_initial_class_config_overrides {
    limit = "1000000Mi"
    name  = "vSAN Default Storage Policy"
  }

  zones_initial_class_config_overrides {
    cpu_limit          = "10000M"
    cpu_reservation    = "0M"
    memory_limit       = "10000Mi"
    memory_reservation = "0Mi"
    name               = var.zone_name
  }
}