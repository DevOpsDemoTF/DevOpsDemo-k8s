data "azurerm_client_config" "current" {}

module "exposed_cluster" {
  source = "./cluster"
  
  client_id = data.azurerm_client_config.current.client_id
  client_secret = var.client_secret
  agent_count = 1
  agent_size = "Standard_D1_v2"
  log_analytics_workspace_name = "LogAnalyticsAdamSzalkowski"
}

