# Reflector for Secret Replication
resource "helm_release" "reflector" {
  name       = "reflector"
  repository = "https://emberstack.github.io/helm-charts"
  chart      = "reflector"
  version    = "7.1.288"
  namespace  = "reflector-system"
  create_namespace = true

  values = [
    yamlencode({
      nameOverride = "reflector"
      fullnameOverride = "reflector"
      
      configuration = {
        logging = {
          minimumLevel = "Information"
        }
        
        watcher = {
          timeout = 300
        }
      }
      
      rbac = {
        enabled = true
      }
      
      serviceMonitor = {
        enabled = false
      }
      
      resources = {
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu    = "50m"
          memory = "64Mi"
        }
      }
      
      nodeSelector = {}
      tolerations = []
      affinity = {}
      
      podSecurityContext = {
        runAsNonRoot = true
        runAsUser = 65534
        runAsGroup = 65534
        fsGroup = 65534
      }
      
      securityContext = {
        allowPrivilegeEscalation = false
        capabilities = {
          drop = ["ALL"]
        }
        readOnlyRootFilesystem = true
        runAsNonRoot = true
        runAsUser = 65534
        runAsGroup = 65534
      }
    })
  ]
}