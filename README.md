# VCF-A terraform Examples

This repo contians a collection of examples how to to interact with VCF-A using terraform. 




## Examples

* [vks cluster](./vks-cluster) -  simple example of creating a supervisor namespace and a vks cluster in the namespace.
* [Virtual machine](./virtual-machine) - simple example of creating a virtual machine and it's required resources.


## FAQ

### Why is the supervisor namespace created in it's own terraform run

This is an issue with the kubernetes provider for terraform and specifically the `manifest` resource. In order to use the manifest resource the provider needs to contact the k8s api during plan in order to validate the CRDs and look up their APIs.  In our case the k8s api is the VCF-A api. The content is targeting the new namespace for deploying the resources. So due to the way that the k8s provider works it needs to have access to  that namespace context during plan, so we need to create the namespace first.