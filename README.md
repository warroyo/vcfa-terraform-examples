# VCF-A terraform Examples

This repo contians a collection of examples how to to interact with VCF-A using terraform. 




## Examples

* [vks cluster](./vks-cluster) -  simple example of creating a supervisor namespace and a vks cluster in the namespace.
* [Virtual machine](./virtual-machine) - simple example of creating a virtual machine and it's required resources.
* [ArgoCD Instance](./argocd/) -  creates a namespace with an instance of ArgoCD in it.
* [ArgoCD e2e](./argo-e2e/) -  end to end of creating a namespace, cluster, argocd instance, and deploying an app
* [ArgoCD cluster](./argocd-cluster/) - deloys a cluster and registers it with ArgoCD
* [Secret Store Integration](./secret-store-vks/) - deloys a cluster, registers it to argocd, creates a secret, registers the cluster with secrets store service and installs the vault injetcor in the cluster


## FAQ

### Why is the supervisor namespace created in it's own terraform run

This is an issue with the kubernetes provider for terraform and specifically the `manifest` resource. In order to use the manifest resource the provider needs to contact the k8s api during plan in order to validate the CRDs and look up their APIs.  In our case the k8s api is the VCF-A api. The content is targeting the new namespace for deploying the resources. So due to the way that the k8s provider works it needs to have access to  that namespace context during plan, so we need to create the namespace first.