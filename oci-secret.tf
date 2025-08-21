resource "kubernetes_secret" "oracle_secret" {
  metadata {
    name      = "oracle-secret"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
    labels = {
      type = "oracle"
    }
    annotations = {
      "reflector.v1.k8s.emberstack.com/reflection-allowed"      = "true"
      "reflector.v1.k8s.emberstack.com/reflection-auto-enabled" = "true"
      "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces" = "monitoring,nextcloud"
    }
  }

  type = "Opaque"

  data = {
    privateKey  = var.oci_private_key
    fingerprint = var.oci_fingerprint
  }
}
