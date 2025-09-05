locals {
  manifest = <<-EOT
    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: cluster-bootstrap
      namespace: ${var.namespace}
    spec:
      goTemplate: true
      goTemplateOptions: ["missingkey=error"]
      generators:
      - clusters:
          selector:
            matchLabels:
              type: 'vks'
      template:
        metadata:
          name: '{{.name}}-cluster-bootstrap'
        spec:
          project: "default"
          source:
            path: ${var.path}
            repoURL: ${var.repo}
            targetRevision: main
            kustomize:
              namePrefix: '{{.name}}-'
              patches:
              - target:
                  kind: Application
                patch: |-
                  - op: replace
                    path: /spec/destination/name
                    value: '{{.name}}'
          destination:
            name: ${var.namespace}
            namespace: ${var.namespace}
          syncPolicy:
            automated:
              prune: true
              selfHeal: true
  EOT
} 


resource "kubernetes_manifest" "bootstrap-app-set" {

  manifest = yamldecode(local.manifest)
  wait {
    condition  {
      status = "True"
      type = "ResourcesUpToDate"
    }
  }
}
