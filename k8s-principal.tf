resource "azuread_application" "k8s" {
  name = local.CName
}

resource "azuread_service_principal" "k8s" {
  application_id = azuread_application.k8s.application_id
}

resource "random_string" "k8s_sp_password" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "k8s" {
  end_date             = "2299-12-30T23:00:00Z"
  service_principal_id = azuread_service_principal.k8s.id
  value                = random_string.k8s_sp_password.result
}
