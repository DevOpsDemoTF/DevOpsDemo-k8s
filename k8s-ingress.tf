resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "azurerm_public_ip" "ingress" {
  name = local.cname
  resource_group_name = azurerm_resource_group.k8s.name
  allocation_method = "Static"
  location = var.location
}

resource "helm_release" "nginx_ingress" {
  name = "nginx-ingress"
  chart = "stable/nginx-ingress"
  namespace = kubernetes_namespace.ingress.metadata.0.name
  force_update = "true"

  timeout = 1200

  set {
    name = "controller.replicaCount"
    value = "3"
  }

  set {
    name = "controller.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name = "defaultBackend.nodeSelector.beta\\.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name = "rbac.create"
    value = "true"
  }

  set {
    name = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.ingress.ip_address
  }

  depends_on = [
    kubernetes_cluster_role_binding.tiller]
}

data "template_file" "certmgr_provider" {
  template = file("${path.module}/templates/letsencrypt-staging.yaml.tpl")
  vars = {
    email = var.letsencrypt_email
  }
}

resource "local_file" "kube_config" {
  sensitive_content = azurerm_kubernetes_cluster.k8s.kube_config_raw
  filename = "${path.module}/.generated/kube_config"
}

variable "certmgr_version" {
  default = "0.9"
}

resource "local_file" "certmgr_provider_spec" {
  content = data.template_file.certmgr_provider.rendered
  filename = "${path.module}/.generated/letsencrypt-staging.yaml"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "certmanager.k8s.io/disable-validation" = "true"
    }
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${local_file.kube_config.filename}' apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-${var.certmgr_version}/deploy/manifests/00-crds.yaml -n cert-manager"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${local_file.kube_config.filename}' apply -f ${local_file.certmgr_provider_spec.filename} -n cert-manager"
  }
}

data "helm_repository" "jetstack" {
  name = "jetstack"
  url = "https://charts.jetstack.io"
}

resource "helm_release" "cert_manager" {
  name = "cert-manager"
  repository = data.helm_repository.jetstack.metadata.0.name
  chart = "jetstack/cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata.0.name
  version = var.certmgr_version
  force_update = "true"

  timeout = 600

  set {
    name = "ingressShim.defaultIssuerName"
    value = "letsencrypt-staging"
  }

  set {
    name = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  depends_on = [
    kubernetes_cluster_role_binding.tiller]
}
