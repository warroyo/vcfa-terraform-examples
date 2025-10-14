
resource "kubernetes_manifest" "kubernetes_cluster" {

  manifest = {
    "apiVersion" = "cluster.x-k8s.io/v1beta1"
    "kind"       = "Cluster"
    "metadata" = {
      "name"      = var.name
      "namespace" =  var.namespace
      "labels" = {
        "kubernetes-cluster-selector" = var.name
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
        "class" =  var.cluster_class,
        "controlPlane" = {
          "replicas" = 1
        },
        "variables" = [
          {
            "name" = "vsphereOptions"
            "value" = {
              "persistentVolumes" = {
                "availableStorageClasses" = [var.storageClass],
                "defaultStorageClass" = var.storageClass
              }
            }
          },
          {
            "name" = "kubernetes",
            "value" = {
              "security" = {
                "podSecurityStandard" = {
                  "deactivated" = true
                }
              },
              "certificateRotation" = {
                "enabled"                 = true,
                "renewalDaysBeforeExpiry" = 15
              }
            }
          },
          {
            "name"  = "vmClass",
            "value" = var.vmClass
          },
          {
            "name"  = "storageClass",
            "value" = var.storageClass
          }
        ],
        "version" = var.k8s_version
        "workers" = {
          "machineDeployments" = [
            {
              "class"    = "node-pool",
              "name"     = var.name
              "replicas" = 1
              "variables" = {
                "overrides" = [
                  {
                    "name"  = "vmClass",
                    "value" = var.vmClass,
                  },
                ],
              }
            }
          ]
        }
      }
    }
  }
  timeouts {
    create = "20m"
  }
  wait {
    fields = {
    "status.v1beta2.conditions[0].status" = "True"
    }
  }
}


data "kubernetes_secret" "cluster-kubeconfig" {
    metadata {
    name = "${var.name}-kubeconfig"
    namespace = var.namespace
  }

  depends_on = [ kubernetes_manifest.kubernetes_cluster ]
}

output "kubeconfig" {
  value = lookup(data.kubernetes_secret.cluster-kubeconfig.data, "value")
  depends_on = [ kubernetes_manifest.kubernetes_cluster ]
  sensitive = true
}