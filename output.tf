output "login" {
  value     = {
    host                   = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    client_key             = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
    client_certificate     = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
    cluster_ca_certificate = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
  }
  sensitive = true
}

output "helm" {
  value = {
    tiller_name      = kubernetes_service_account.tiller.metadata.0.name
    tiller_namespace = "kube-system"
  }
}

output "fqdn" {
  value = azurerm_public_ip.ingress.fqdn
}

output "dashboard_url" {
  value = "https://${azurerm_public_ip.ingress.fqdn}/"
}

output "environment" {
  value     = {
    name      = var.environment
    principal = azuread_service_principal.k8s.object_id
    kube_conf = azurerm_kubernetes_cluster.k8s.kube_config_raw
  }
  sensitive = true
}
