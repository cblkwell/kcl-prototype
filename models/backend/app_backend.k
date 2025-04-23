import k8s.api.apps.v1 as appsv1
import k8s.api.core.v1 as corev1
import secrets_store_csi_driver.v1 as secretsv1
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

  serviceSecret = secretsv1.SecretProviderClass {
    metadata.name = "${config.name}-app-secret"
    metadata.namespace = config.namespace
    spec = {
      provider = "aws"
      parameters = {
        objects = """objectName: services/${config.name}
objectType: "secretsmanager"
"""
      }
    }
  }

  if config.cloud_provider == "gcp":
    serviceSecretCloud = app.Secret {
      metadata.name = "${config.name}-app-secret"
      spec = {
        forProvider = {
          project = "/project/my-gcp-project"
          labels = {
            owner = "fet"
          }
          replication = [{
            auto = [{}]
          }]
        }
      }
    }

  metadataSecret = secretsv1.SecretProviderClass {
    metadata.name = "${config.name}-metadata"
    metadata.namespace = config.namespace
    spec = {
      provider = "aws"
      parameters = {
        objects = """objectName: metadata/${config.name}
objectType: "secretsmanager"
"""
      }
    }
  }

  if config.ref_secrets:
    globalRefSecrets: [secretsv1.SecretProviderClass] = [
      app.RefSecret(_s, config.namespace, config.cloud_provider).secret for _i, _s in config.ref_secrets
    ]

  secretProviderClasses: [secretsv1.SecretProviderClass] = sum([[serviceSecret, metadataSecret],globalRefSecrets],[])
  gcpSecrets: [app.Secret] = [serviceSecretCloud]

  kubernetes: resource.ResourceMapping = {
    "ConfigMap" = [globalEnvConfigMap]
    "ServiceAccount" = [serviceAccount]
    "SecretProviderClass" = [secretProviderClasses]
    "Secret" = [gcpSecrets]
  }
