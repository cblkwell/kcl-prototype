import k8s.api.core.v1 as corev1

protocol DeployEnvProtocol:
  env_vars?: {str:str}

mixin DeployEnvMixin for DeployEnvProtocol:
  deployConfigMap?: corev1.ConfigMap

  deployConfigMap = corev1.ConfigMap {
    metadata.name = "test-app-env"
    metadata.namespace = "services"
    data = env_vars
  }
