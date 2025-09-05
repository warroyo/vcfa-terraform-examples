# Supervisor namespace Cluster Boostrap

the purpose of this module is to create an argocd app set in the supervisor namespace that the argocd instance is deployed into. Thsi app set will be used for bootsrapping the cluster with components that it needs. Typically this use case if for infra or platform teams to install things like observability, ingress, etc. prior to handing off the cluster. 