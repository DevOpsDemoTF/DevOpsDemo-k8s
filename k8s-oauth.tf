resource "azuread_application" "oauth" {
  name = "${local.CName} Dashboard"
  type = "webapp/api"
  available_to_other_tenants = false
  homepage = "https://${azurerm_public_ip.ingress.fqdn}/"
  reply_urls = [
    "https://${azurerm_public_ip.ingress.fqdn}/oauth2/callback"
  ]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

resource "azuread_application_password" "oauth" {
  end_date = "2299-12-30T23:00:00Z"
  application_object_id = azuread_application.oauth.object_id
  value = random_string.dashboard_app_secret.result
}

resource "random_string" "dashboard_app_secret" {
  length = 32
  special = true
}

resource "kubernetes_namespace" "oauth" {
  metadata {
    name = "oauth"
  }
}

resource "random_string" "oauth_proxy_client_secret" {
  length = 32
}

data "azurerm_client_config" "current" {}

# docker run -ti --rm python:3-alpine python -c 'import secrets,base64; print(base64.b64encode(base64.b64encode(secrets.token_bytes(16))));'
resource "kubernetes_secret" "oauth_proxy" {
  metadata {
    name = "oauth2-proxy"
    namespace = kubernetes_namespace.oauth.metadata.0.name
  }

  data = {
    "OAUTH2_PROXY_CLIENT_ID" = azuread_application.oauth.application_id
    "OAUTH2_PROXY_CLIENT_SECRET" = azuread_application_password.oauth.value
    "OAUTH2_PROXY_COOKIE_SECRET" = random_string.oauth_proxy_client_secret.result
    "OAUTH2_PROXY_AZURE_TENANT" = data.azurerm_client_config.current.tenant_id
  }
}

resource "kubernetes_deployment" "oauth_proxy" {
  metadata {
    name = "oauth2-proxy"
    namespace = kubernetes_namespace.oauth.metadata.0.name
    labels = {
      app = "oauth2-proxy"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "oauth2-proxy"
      }
    }

    template {
      metadata {
        labels = {
          app = "oauth2-proxy"
        }
      }
      spec {
        container {
          name = "oauth2-proxy"
          image = "quay.io/pusher/oauth2_proxy:latest"
          image_pull_policy = "Always"

          args = [
            "--provider=azure",
            "--email-domain=*",
            "--upstream=file:///dev/null",
            "--http-address=0.0.0.0:4180",
            "--pass-access-token=true",
            "--pass-authorization-header=true"
          ]

          port {
            container_port = 4180
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.oauth_proxy.metadata.0.name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "oauth_proxy" {
  metadata {
    name = "oauth2-proxy"
    namespace = kubernetes_namespace.oauth.metadata.0.name
  }

  spec {
    selector = {
      app = "oauth2-proxy"
    }

    port {
      name = "http"
      port = 4180
      target_port = "4180"
    }
  }
}

resource "kubernetes_ingress" "oauth_proxy" {
  metadata {
    name = "oauth2-proxy"
    namespace = kubernetes_namespace.oauth.metadata.0.name

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme" = "true"
      "nginx.ingress.kubernetes.io/rewrite-target": "/oauth2"
    }
  }

  spec {
    tls {
      hosts = [
        azurerm_public_ip.ingress.fqdn]
      secret_name = "oauth2-proxy-tls"
    }

    rule {
      host = azurerm_public_ip.ingress.fqdn
      http {
        path {
          path = "/oauth2"
          backend {
            service_name = kubernetes_service.oauth_proxy.metadata.0.name
            service_port = "4180"
          }
        }
      }
    }
  }
}
