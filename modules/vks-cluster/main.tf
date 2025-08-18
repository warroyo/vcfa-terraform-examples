
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
        "class" = "builtin-generic-v3.3.0",
        "controlPlane" = {
          "replicas" = 1
        },
        "variables" = [
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
        "version" = "v1.32.0+vmware.6-fips"
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
  wait {
    condition {
      type = "Ready"
      status = "True"
    }
  }
}


data "kubernetes_secret" "cluster-kubeconfig" {
    metadata {
    name = "${var.name}-kubeconfig"
    namespace = var.namespace
  }

  # binary_data = {
  #   value = "LS0tCg=="
  # }
  depends_on = [ kubernetes_manifest.kubernetes_cluster ]
}

output "kubeconfig" {
  value = lookup(data.kubernetes_secret.cluster-kubeconfig.data, "value")
  depends_on = [ kubernetes_manifest.kubernetes_cluster ]
  sensitive = true
}