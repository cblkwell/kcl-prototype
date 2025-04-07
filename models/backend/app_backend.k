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
    metadata.name = "${config.name}-services"
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
      metadata.name = "${config.name}-services"
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
    metadata.name = "${config.name}-service-metadata"
    metadata.namespace = config.namespace
    spec = {
      provider = "aws"
      parameters = {
        objects = """objectName: service-metadata/${config.name}
objectType: "secretsmanager"
"""
      }
    }
  }

  if config.cloud_provider == "gcp":
    metadataSecretCloud = app.Secret {
      metadata.name = "${config.name}-service-metadata"
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

  refSecrets: [secretsv1.SecretProviderClass] = [ secretsv1.SecretProviderClass {
    metadata.name = _s
    metadata.namespace = config.namespace
    spec = {
      provider = config.cloud_provider
      parameters = {
        if config.cloud_provider == "aws":
          objects = """objectname: ${_s}
objectType: "secretsmanager"
"""
        elif config.cloud_provider == "gcp":
          secrets = """resourceName: "projects/my-gcp-project/secrets/${_s}/versions/latest"
path: ${_s}
"""
      }
    } 
  } for _i, _s in config.ref_secrets ] + [serviceSecret]

  createSecrets: [app.Secret] = []

  if config.create_secrets:
    if config.cloud_provider == "gcp":
      createSecrets = [ app.Secret {
        metadata.name = _s
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
      } for _i, _s in config.create_secrets] + [serviceSecretCloud, metadataSecretCloud]

  kubernetes: resource.ResourceMapping = {
    "ConfigMap" = [globalEnvConfigMap]
    "ServiceAccount" = [serviceAccount]
    "SecretProviderClass" = refSecrets + [metadataSecret]
    "Secret" = [createSecrets]
  }
