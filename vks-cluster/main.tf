
locals {
  cluster_name = "lab-1"
  region_name = var.region_name
  vpc_name = var.vpc_name
  zone_name = var.zone_name
}

module "supervisor_namespace" {
  source = "../modules/namespace"
  zone_name = local.zone_name
  region_name = local.region_name
  vpc_name = local.vpc_name
}



resource "kubernetes_manifest" "kubernetes_cluster" {

  manifest = {
    "apiVersion" = "cluster.x-k8s.io/v1beta1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = local.cluster_name
      "namespace" =  module.supervisor_namespace.namespace
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
