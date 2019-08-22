output "k8s_client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
  sensitive = true
}

output "k8s_client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
  sensitive = true
}

output "k8s_cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "k8s_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}

output "k8s_host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}

output "k8s_fqdn" {
  value = azurerm_public_ip.ingress.fqdn
}

output "k8s_service_principal" {
  value = azuread_service_principal.k8s.object_id
}

output "tiller_name" {
  value = kubernetes_service_account.tiller.metadata.0.name
}

output "tiller_namespace" {
  value = "kube-system"
}

output "k8s_dashboard_url" {
  value = "https://${azurerm_public_ip.ingress.fqdn}/"
}
