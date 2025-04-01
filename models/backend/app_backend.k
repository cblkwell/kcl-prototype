import k8s.api.apps.v1 as appsv1
import k8s.api.core.v1 as corev1
import konfig.models.kube.resource
import konfig.models.kube.utils

import models.app
import models.mixins

schema AppBackend[inputConfig: app.App]:
  mixin [
    mixins.DeploymentMixin
  ]
  # We need to set a variable for mixins to pull in.
  config: app.App = inputConfig

  globalEnvConfigMap = corev1.ConfigMap {
    metadata: {
      name: "${config.name}-global-env"
      namespace: config.namespace
    }
    data = config.global_env_vars
  }

  serviceAccount = corev1.ServiceAccount {
    metadata: {
      name: "${config.name}-default"
      namespace: config.namespace
    }
  }

  #if config.deployments:
  #  deployments = [ DeployBackend(d, config.name, config.namespace) for _, d in config.deployments ]
  #  deploy_kube = [ inst?.kubernetes for _, inst in deployments ]

  kubernetes: resource.ResourceMapping = {
      "ConfigMap" = [globalEnvConfigMap]
      "ServiceAccount" = [serviceAccount]
  }
