# Azure AKS Kubernetes cluster #
This Terraform module creates a Kubernetes cluster 
for use as a deployment environment for my [DevOpsDemo](https://github.com/DevOpsDemoTF/DevOpsDemo)

### Requirements ###
* Terraform v0.12+
* Azure CLI
* kubectl
* helm
* (Optional) Azure Service Principal for Terraform

### Features ###
* AKS Kubernetes cluster
* Kubernetes dashboard protected with OAuth2 via Azure Active Directory
* Nginx ingress controller
* Certificate manager for [Let's Encrypt - SSL/TLS certificates](https://letsencrypt.org/)
* Azure Metrics collector for Prometheus metrics

### Links ###
* https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure
* https://docs.microsoft.com/en-us/azure/terraform/terraform-create-k8s-cluster-with-tf-and-aks
* https://docs.microsoft.com/en-us/azure/aks/ingress-tls
* https://docs.microsoft.com/en-us/azure/aks/ingress-static-ip
* https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-agent-config

