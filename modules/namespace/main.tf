resource "vcfa_supervisor_namespace" "supervisor_namespace" {
  name_prefix  = var.name
  project_name = "default-project"
  class_name   = var.class_name
  description  = "Supervisor Namespace with prefix [lab] created by Terraform"
  region_name  = var.region_name
  vpc_name     = var.vpc_name

  storage_classes_initial_class_config_overrides {
    limit = var.storage_limit
    name  = "vSAN Default Storage Policy"
  }

  zones_initial_class_config_overrides {
    cpu_limit          = var.cpu_limit
    cpu_reservation    = "0M"
    memory_limit       = var.mem_limit
    memory_reservation = "0Mi"
    name               = var.zone_name
  }
}