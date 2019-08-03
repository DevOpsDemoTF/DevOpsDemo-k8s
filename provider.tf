variable "client_secret" {}

provider "azurerm" {
    version = "~>1.5"
    client_secret = var.client_secret
}

provider "kubernetes" {
    host = module.exposed_cluster.host

    client_certificate     = base64decode(module.exposed_cluster.client_certificate)
    client_key             = base64decode(module.exposed_cluster.client_key)
    cluster_ca_certificate = base64decode(module.exposed_cluster.cluster_ca_certificate)
}

provider "helm" {
    kubernetes {
        host = module.exposed_cluster.host

        client_certificate     = base64decode(module.exposed_cluster.client_certificate)
        client_key             = base64decode(module.exposed_cluster.client_key)
        cluster_ca_certificate = base64decode(module.exposed_cluster.cluster_ca_certificate)
    }
}

terraform {
    backend "azurerm" {
        resource_group_name  = "terraform"
        storage_account_name = "adamszalkowskiterraform"
        container_name       = "terraform-state"
        key                  = "prod.terraform.tfstate"
    }
}
