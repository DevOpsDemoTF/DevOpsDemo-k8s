variable "client_secret" {}

provider "azurerm" {
    version = "~>1.5"
    client_secret = "${var.client_secret}"
}

terraform {
    backend "azurerm" {
        resource_group_name  = "terraform"
        storage_account_name = "adamszalkowskiterraform"
        container_name       = "terraform-state"
        key                  = "prod.terraform.tfstate"
    }
}
