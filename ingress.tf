resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

resource "helm_release" "nginx_ingress" {
    name      = "nginx-ingress"
    chart     = "stable/nginx-ingress"
    namespace = kubernetes_namespace.ingress.metadata.0.name
    force_update = "true"

    timeout = 600

    set {
        name  = "controller.replicaCount"
        value = "2"
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
        value = "false"
    }

    set {
        name = "controller.service.externalTrafficPolicy"
        value = "Local"
    }

    depends_on = [kubernetes_namespace.ingress]
}

variable "letsencrypt_email" {}

///// TODO: FIX AS SOON AS cert-manager installs CRDs automatically or terraform provider supports CRDs
data "template_file" "certmgr_provider" {
  template = "${file("${path.module}/letsencrypt-staging.yaml.tpl")}"
  vars = {
    email = var.letsencrypt_email
  }
}

resource "local_file" "kube_config" {
    sensitive_content = module.exposed_cluster.kube_config
    filename = "${path.module}/kube_config"
}

variable "certmgr_version" {
    default = "0.9"
}

resource "null_resource" "certmgr_crds" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${local_file.kube_config.filename}' apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-${var.certmgr_version}/deploy/manifests/00-crds.yaml"
  }

  depends_on = [kubernetes_namespace.cert_manager, local_file.kube_config]
}

resource "local_file" "certmgr_provider_spec" {
    content = data.template_file.certmgr_provider.rendered
    filename = "${path.module}/letsencrypt-staging.yaml"
}

resource "null_resource" "certmgr_provider" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig='${local_file.kube_config.filename}' apply -f ${local_file.certmgr_provider_spec.filename}"
  }

  depends_on = [null_resource.certmgr_crds, local_file.kube_config, local_file.certmgr_provider_spec]
}
///// END TODO

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
        "certmanager.k8s.io/disable-validation" = "true"
    }
  }
}

data "helm_repository" "jetstack" {
    name = "jetstack"
    url  = "https://charts.jetstack.io"
}

resource "helm_release" "cert_manager" {
    name      = "cert-manager"
    repository = data.helm_repository.jetstack.metadata.0.name
    chart     = "jetstack/cert-manager"
    namespace = kubernetes_namespace.cert_manager.metadata.0.name
    version   = var.certmgr_version
    force_update = "true"

    timeout = 600

    set {
        name  = "ingressShim.defaultIssuerName"
        value = "letsencrypt-staging"
    }

    set {
        name  = "ingressShim.defaultIssuerKind"
        value = "ClusterIssuer"
    }

    depends_on = [null_resource.certmgr_crds, null_resource.certmgr_provider]
}
