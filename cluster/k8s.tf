resource "azurerm_resource_group" "k8s" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

resource "azurerm_log_analytics_workspace" "test" {
    name                = "${var.log_analytics_workspace_name}"
    location            = "${var.log_analytics_workspace_location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    sku                 = "${var.log_analytics_workspace_sku}"
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = "${azurerm_log_analytics_workspace.test.location}"
    resource_group_name   = "${azurerm_resource_group.k8s.name}"
    workspace_resource_id = "${azurerm_log_analytics_workspace.test.id}"
    workspace_name        = "${azurerm_log_analytics_workspace.test.name}"

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = "${var.cluster_name}"
    location            = "${azurerm_resource_group.k8s.location}"
    resource_group_name = "${azurerm_resource_group.k8s.name}"
    dns_prefix          = "${var.dns_prefix}"

    //linux_profile {
    //    admin_username = "ubuntu"
    //
    //    ssh_key {
    //        key_data = "${file("${var.ssh_public_key}")}"
    //    }
    //}

    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.agent_count}"
        vm_size         = "${var.agent_size}"
        os_type         = "Linux"
        os_disk_size_gb = 30
    }

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = "${azurerm_log_analytics_workspace.test.id}"
        }
    }

    tags = {
        Environment = "Development"
    }
}
