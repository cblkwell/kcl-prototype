import k8s.api.core.v1 as corev1

schema App:
  name: str
  namespace: str = "services"
  global_env_vars?: {str:str}
  image: str
  deployments?: {str:Deploy}
  cloud_provider?: "aws" | "gcp"
  create_secrets?: [str]
  ref_secrets?: [str]
  authorized_callers?: [str]

schema Deploy:
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
