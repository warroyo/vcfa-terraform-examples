module "vks" {
  source = "../modules/vks-cluster"
  name = var.cluster
  namespace = var.namespace
  vmClass = "best-effort-large"
}

locals {
  kubeconfig = yamldecode(sensitive(module.vks.kubeconfig))
  sample_secret_manifest = <<-EOT
    kind: KeyValueSecret
    apiVersion: secretstore.vmware.com/v1alpha1
    metadata:
      name: db-cred2
      namespace: ${var.namespace}
    spec:
      name: db-cred
      data:
        - key: username
          value: dbuser
        - key: password
          value: dbpassword
  EOT
}
resource "kubernetes_manifest" "sample-secret" {
  manifest = yamldecode(local.sample_secret_manifest)
}

module "secret-store-register" {
  source = "../modules/secret-store-vks-auth"
  cluster-ca = local.kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"]
  cluster-host = local.kubeconfig["clusters"][0]["cluster"]["server"]
  cluster-name = var.cluster
  supervisor-namespace = var.namespace
}

module "argo-attach" {
  source = "../modules/argo-attach-cluster"
  cluster_name = var.cluster
  kubeconfig = module.vks.kubeconfig
  namespace = var.namespace

}

locals {
  injetcor_manifest = <<-EOT
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: ${var.cluster}-secret-store-injector
      namespace: ${var.namespace}
    spec:
      project: "default"
      source:
        path: ./secretstore/source
        repoURL: https://github.com/warroyo/vks-argocd-examples
        targetRevision: main
        kustomize:
          patches:
          - target:
              kind: Deployment
              name: vault-injector
            patch: |-
              apiVersion: apps/v1
              kind: Deployment
              metadata:
                name: vault-injector
                namespace: secret-store-injector
              spec:
                template:
                  spec:
                    containers:
                      - name: sidecar-injector
                        env:
                          - name: AGENT_INJECT_VAULT_ADDR
                            value: ${var.vault_url}
      destination:
        name: ${var.cluster}
        namespace: secret-store-injector
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - CreateNamespace=true
  EOT
}

resource "kubernetes_manifest" "argo-app-secret-injector" {
  manifest = yamldecode(local.injetcor_manifest)
}