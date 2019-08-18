/*
Full resource list can be generated via:

#!/usr/bin/python3
import subprocess
resources = dict()
with subprocess.Popen(["kubectl", "api-resources", "-o", "name"], stdout=subprocess.PIPE) as p:
    for l in p.stdout:
        l = l.strip().split(b'.', 1)
        api = (l[1] if len(l) > 1 else b"").decode()
        resource = (l[0]).decode()
        resources[api] = resources.get(api, list()) + [resource]

for r,l in resources.items():
    s = """rule {{
    api_groups = ["{}"]
    resources = {}
    verbs = ["get", "list", "watch"]
}}
""".format(r, '["' + '", "'.join(sorted(l)) + '"]')
    print(s)
*/

resource "kubernetes_cluster_role" "dashboard" {
  metadata {
    name = "dashboard-role-custom"
  }

  rule {
    api_groups = [
      ""]
    resources = [
      "bindings",
      "componentstatuses",
      "configmaps",
      "endpoints",
      "events",
      "limitranges",
      "namespaces",
      "nodes",
      "persistentvolumeclaims",
      "persistentvolumes",
      "pods",
      "podtemplates",
      "replicationcontrollers",
      "resourcequotas",
      "serviceaccounts",
      "services"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      ""]
    resources = [
      "secrets"]
    verbs = [
      "list"]
  }

  rule {
    api_groups = [
      "apiextensions.k8s.io"]
    resources = [
      "customresourcedefinitions"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "apps"]
    resources = [
      "controllerrevisions",
      "daemonsets",
      "deployments",
      "replicasets",
      "statefulsets"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "autoscaling"]
    resources = [
      "horizontalpodautoscalers"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "batch"]
    resources = [
      "cronjobs",
      "jobs"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "certificates.k8s.io"]
    resources = [
      "certificatesigningrequests"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "certmanager.k8s.io"]
    resources = [
      "certificaterequests",
      "certificates",
      "challenges",
      "clusterissuers",
      "issuers",
      "orders"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "coordination.k8s.io"]
    resources = [
      "leases"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "events.k8s.io"]
    resources = [
      "events"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "extensions"]
    resources = [
      "daemonsets",
      "deployments",
      "ingresses",
      "networkpolicies",
      "podsecuritypolicies",
      "replicasets"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "metrics.k8s.io"]
    resources = [
      "nodes",
      "pods"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "networking.k8s.io"]
    resources = [
      "networkpolicies"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "policy"]
    resources = [
      "poddisruptionbudgets",
      "podsecuritypolicies"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "rbac.authorization.k8s.io"]
    resources = [
      "clusterrolebindings",
      "clusterroles",
      "rolebindings",
      "roles"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "scheduling.k8s.io"]
    resources = [
      "priorityclasses"]
    verbs = [
      "get",
      "list",
      "watch"]
  }

  rule {
    api_groups = [
      "storage.k8s.io"]
    resources = [
      "storageclasses",
      "volumeattachments"]
    verbs = [
      "get",
      "list",
      "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "dashboard" {
  metadata {
    name = "dashboard-role-custom"
  }

  subject {
    api_group = ""
    kind = "ServiceAccount"
    name = "kubernetes-dashboard"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = kubernetes_cluster_role.dashboard.metadata.0.name
  }
}

resource "kubernetes_ingress" "dashboard" {
  metadata {
    name = "dashboard"
    namespace = "kube-system"

    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme" = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/auth-url" = "https://$host/oauth2/auth"
      "nginx.ingress.kubernetes.io/auth-signin" = "https://$host/oauth2/start?rd=$request_uri"
    }
  }

  spec {
    tls {
      hosts = [
        azurerm_public_ip.ingress.fqdn]
      secret_name = "kubernetes-dashboard-tls"
    }

    rule {
      host = azurerm_public_ip.ingress.fqdn
      http {
        path {
          path = "/"
          backend {
            service_name = "kubernetes-dashboard"
            service_port = "80"
          }
        }
      }
    }
  }
}