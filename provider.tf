provider "kubernetes" {
  version = "~>1.8"
  host    = azurerm_kubernetes_cluster.k8s.kube_config.0.host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  version         = "~>0.10"
  namespace       = kubernetes_service_account.tiller.metadata.0.namespace
  service_account = kubernetes_service_account.tiller.metadata.0.name

  kubernetes {
    host = azurerm_kubernetes_cluster.k8s.kube_config.0.host

    client_certificate     = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
  }
}