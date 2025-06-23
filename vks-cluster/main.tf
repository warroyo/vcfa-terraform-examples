
locals {
  cluster_name = "lab-1"
  region_name = "west"
  vpc_name = "west-Default-VPC"
  zone_name = "z-wld-a"
}

resource "vcfa_supervisor_namespace" "supervisor_namespace" {
  name_prefix  = "lab"
  project_name = "default-project"
  class_name   = "small"
  description  = "Supervisor Namespace with prefix [lab] created by Terraform"
  region_name  = local.region_name
  vpc_name     = local.vpc_name

  storage_classes_initial_class_config_overrides {
    limit = "1000000Mi"
    name  = "vSAN Default Storage Policy"
  }

  zones_initial_class_config_overrides {
    cpu_limit          = "10000M"
    cpu_reservation    = "0M"
    memory_limit       = "10000Mi"
    memory_reservation = "0Mi"
    name               = local.zone_name
  }
}


resource "kubernetes_manifest" "kubernetes_cluster" {

  manifest = {
    "apiVersion" = "cluster.x-k8s.io/v1beta1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = local.cluster_name
      "namespace" = resource.vcfa_supervisor_namespace.supervisor_namespace.name
      "labels" = {
        "kubernetes-cluster-selector" = local.cluster_name
      }
    },
    "spec" = {
      "clusterNetwork" = {
        "pods" = {
          "cidrBlocks" = ["192.168.156.0/20"],
        },
        "services" = {
          "cidrBlocks" = ["10.96.0.0/12"],
        },
        "serviceDomain" = "cluster.local"
      },
      "topology" = {
        "class" = "builtin-generic-v3.3.0",
        "controlPlane" = {
          "replicas" = 1
        },
        "variables" = [
          {
            "name" = "kubernetes",
            "value" = {
              "certificateRotation" = {
                "enabled"                 = true,
                "renewalDaysBeforeExpiry" = 15
              }
            }
          },
          {
            "name"  = "vmClass",
            "value" = "best-effort-xsmall"
          },
          {
            "name"  = "storageClass",
            "value" = "vsan-default-storage-policy"
          }
        ],
        "version" = "v1.32.0+vmware.6-fips"
        "workers" = {
          "machineDeployments" = [
            {
              "class"    = "node-pool",
              "name"     = local.cluster_name
              "replicas" = 1
              "variables" = {
                "overrides" = [
                  {
                    "name"  = "vmClass",
                    "value" = "best-effort-small",
                  },
                ],
              }
            }
          ]
        }
      }
    }
  }
}
