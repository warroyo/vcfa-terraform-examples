
locals {
  vm_name = "sample-vm"
  region_name = "west"
  vpc_name = "west-Default-VPC"
  zone_name = "z-wld-a"
  network_name = "vm-default"
}


data "vcfa_org" "acme" {
  name = "acme"
}

data "vcfa_region" "region" {
  name = "west"
}

data "vcfa_storage_class" "sc" {
  region_id = data.vcfa_region.region.id
  name      = "vSAN Default Storage Policy"
}

resource "vcfa_content_library" "cl" {
  org_id      = data.vcfa_org.acme.id
  name        = "My Library"
  description = "A simple library"
  storage_class_ids = [
    data.vcfa_storage_class.sc.id
  ]
}

resource "null_resource" "ova_download" {
    provisioner "local-exec" {
    command = "curl -sS -o ${path.module}/ubuntu.ova https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.ova"
        interpreter = ["bash", "-c"]
     }

    triggers = {
     always_run = "${timestamp()}"
    }
 }

resource "vcfa_content_library_item" "ova" {
  name               = "ubuntu"
  description        = "simple ubuntu image"
  content_library_id = vcfa_content_library.cl.id
  file_paths         = ["${path.module}/ubuntu.ova"]
  depends_on = [ null_resource.ova_download ]
}

module "supervisor_namespace" {
  source = "../modules/namespace"
  zone_name = local.zone_name
  region_name = local.region_name
  vpc_name = local.vpc_name
}

resource "kubernetes_manifest" "virtual_machine_lb" {
  manifest = {
    "apiVersion" = "vmoperator.vmware.com/v1alpha3",
    "kind"       = "VirtualMachineService",
    "metadata" = {
      "name"      = local.vm_name
      "namespace" = module.supervisor_namespace.namespace
    },
    "spec" = {
      "ports" = [
        {
          "name"       = "http",
          "protocol"   = "TCP",
          "port"       = "22",
          "targetPort" = "22"
        },
      ],
      "selector" = {
        (local.vm_name) = "vm-lb-selector"
      },
      "type" = "LoadBalancer",
    }
  }
}



resource "kubernetes_secret" "virtual_machine_secret" {
  metadata {
    name      = local.vm_name
    namespace = module.supervisor_namespace.namespace
    labels = {
      vm-selector = local.vm_name
    }
  }

  data = {
    password = bcrypt(var.vm_user_password)
  }

  type = "kubernetes.io/basic-auth"
}


resource "kubernetes_manifest" "virtual_machine" {

  manifest = {
    "apiVersion" = "vmoperator.vmware.com/v1alpha3"
    "kind"       = "VirtualMachine"
    "metadata" = {
      "name"      = local.vm_name
      "namespace" = module.supervisor_namespace.namespace
      "labels" = {
        "vm-selector"            = local.vm_name,
        (local.vm_name) = "vm-lb-selector"
      }
    }
    "spec" = {
      "bootstrap" = {
        "cloudInit" = {
          "cloudConfig" = {
            "defaultUserEnabled" = true,
            "ssh_pwauth"         = true,
            "users" = [
              {
                "name"        = "vmware-user"
                "lock_passwd" = false
                "passwd" = {
                  "name" = resource.kubernetes_secret.virtual_machine_secret.metadata[0].name,
                  "key"  = "password"
                }
                "sudo" = "ALL=(ALL) NOPASSWD:ALL"
              }
            ]
          }
        }
      }
      "className" = "best-effort-small"
      "imageName" = resource.vcfa_content_library_item.ova.image_identifier
      "network" = {
        "interfaces" = [
          {
            "name" = "eth0"
            "network" = {
              "kind" = "SubnetSet"
              "name" = local.network_name
            }
          }
        ]
      }
      "powerOffMode" = "TrySoft"
      "powerState"   = "PoweredOn"
      "restartMode"  = "TrySoft"
      "storageClass" = replace(lower(data.vcfa_storage_class.sc.name)," ","-")
      "suspendMode"  = "TrySoft"
    }
  }

  wait {
    fields = {
      "status.powerState" = "PoweredOn"
    }
  }

  lifecycle {
    ignore_changes = [
      object[0].metadata[0].annotations["vmoperator.vmware.com/backup-version"],
    ]
  }
}
