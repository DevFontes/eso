# External Secrets Operator Configuration

# ESO Namespace
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
    labels = {
      "pod-security.kubernetes.io/enforce" = "restricted"
      "pod-security.kubernetes.io/audit"   = "restricted"
      "pod-security.kubernetes.io/warn"    = "restricted"
    }
  }
}

# External Secrets Operator Installation
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.19.2"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name

  values = [
    file("${path.module}/files/values.yaml")
  ]
}

# Note: Each project will create its own SecretStores and ExternalSecrets
# This ESO deployment provides the base infrastructure
