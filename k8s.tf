resource "azurerm_resource_group" "k8s" {
  name     = local.CName
  location = var.location
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = local.CName
  location            = var.location
  resource_group_name = azurerm_resource_group.k8s.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "test" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.test.location
  resource_group_name   = azurerm_resource_group.k8s.name
  workspace_resource_id = azurerm_log_analytics_workspace.test.id
  workspace_name        = azurerm_log_analytics_workspace.test.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = local.cname
  location            = azurerm_resource_group.k8s.location
  resource_group_name = azurerm_resource_group.k8s.name
  dns_prefix          = local.cname

  agent_pool_profile {
    name            = "agentpool"
    count           = var.k8s_agent_count
    vm_size         = var.k8s_agent_size
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = azuread_service_principal.k8s.application_id
    client_secret = azuread_service_principal_password.k8s.value
  }

  role_based_access_control {
    enabled = true
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
    }
  }

  tags = {
    Environment = var.environment
  }
}

resource "kubernetes_config_map" "metrics" {
  metadata {
    name      = "container-azm-ms-agentconfig"
    namespace = "kube-system"
  }

  data = {
    "schema-version"                     = "v1"
    "config-version"                     = "ver1"
    "log-data-collection-setting"        = file("${path.module}/templates/log-data-collection-settings.cfg")
    "prometheus-data-collection-setting" = file("${path.module}/templates/prometheus-data-collection-settings.cfg")
  }
}