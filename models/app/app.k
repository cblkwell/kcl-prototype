import k8s.api.core.v1 as corev1
import secrets_store_csi_driver.v1 as secretsv1

schema App:
  name?: str
  namespace: str = "services"
  global_env_vars?: {str:str}
  image: str = option("image")
  deployments?: {str:Deploy}
  cloud_provider: "aws" | "gcp" = option("cloud")
  create_secrets?: [str]
  ref_secrets?: [str]
  authorized_callers?: [str]

schema Deploy:
  suffix?: str
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

schema RefSecret[secret_name: str, secret_namespace: str, cloud: str]:
  secret: secretsv1.SecretProviderClass = secretsv1.SecretProviderClass {
    metadata.name = secret_name
    metadata.namespace = secret_namespace
    spec = {
      provider = cloud
      parameters = {
        if cloud == "aws":
          objects = """objectname: ${secret_name}
objectType: "secretsmanager"
"""
        elif cloud == "gcp":
          secrets = """resourceName: "projects/my-gcp-project/secrets/${secret_name}/versions/latest"
path: ${secret_name}
"""
      }
    }
  }
