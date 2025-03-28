import k8s.api.core.v1 as corev1
import models.mixins

schema App:
  name: str
  global_env_vars?: {str:str}
  image: str
  deployments?: {str:Deploy}
  cloud_provider?: "aws" | "gcp"
  create_secrets?: [str]
  global_ref_secrets?: [str]

schema Deploy:
  mixin [mixins.DeployEnvMixin]
 
  suffix: str
  service_account?: str
  env_vars?: {str:str}
  replicas: int = 2
  resources: corev1.ResourceRequirements = {
    limits = {
      cpu = "1"
      memory = "1Gi"
      disk = "20Gi"
    }
  requests = {
      cpu = "500m"
      memory = "512Mi"
      disk = "10Gi"
    }
  }
  service?: bool = False
  ref_secrets?: [str]
  ports: [corev1.ContainerPort] = [
    {
      name = "healthcheck"
      containerPort: 3001
      protocol = "TCP"
    },
    {
      name = "https"
      containerPort: 3443
      protocol: "TCP"
    }
  ]
