import k8s.api.apps.v1 as appsv1
import k8s.api.core.v1 as corev1
import konfig.models.kube.resource
import konfig.models.kube.utils

import models.app

schema DeployBackend[inputConfig: app.Deploy, parent: str, namespace: str]:

  # Making these an attribute of the schema so mixins can use them, if I
  # want to use them later.
  config: app.Deploy = inputConfig
  appName = parent
  appNamespace = namespace

  _workload = appsv1.Deployment {
    metadata.name = "${appName}-${config.suffix}"
    metadata.namespace = appNamespace
    spec = {
      replicas = config.replicas
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "${appName}-${config.suffix}"
        }
      }
      template.spec.containers = [
        {
          name = "${appName}-${config.suffix}"
          image = "myimage.image"
          command = [ "bash", "-c", "node .node_modules/.bin/redox-start -- src/index.ts" ]
          env = [{
            name = "MY_POD_NAME"
            valueFrom = {
              fieldRef = {
                apiVersion = "v1"
                fieldPath = "metadata.name"
              }
            }
          }, {
            name ="MY_POD_NAMESPACE"
            valueFrom = {
              fieldRef = {
                apiVersion = "v1"
                fieldPath = "metadata.namespace"
              }
            }
          }]
          envFrom = [{
            configMapRef = {
              name = "cluster-constants"
            }
          }, {
            configMapRef = {
              name = "${appName}-global-env"
            }
          }]
          resources = config.resources
          ports = config.ports
        }
      ]
    }
  }

  if config.env_vars:
    _envConfig = corev1.ConfigMap {
      metadata: {
        name: "${appName}-${config.suffix}-env"
        namespace: appNamespace
      }
      data = config.env_vars
    }

  if config.service:
    _service = corev1.Service {
      metadata: {
        name = "${appName}-${config.suffix}"
        namespace = appNamespace

      }
      spec: {
        type = "ClusterIP"
        ports: [{
          name = "https"
          port = 443
          targetPort = 3443
        }]
        selector = {
          "app.kubernetes.io/component" = config.suffix
          "app.kubernetes.io/part-of" = appName
        }
      }
    }

  kubernetes: resource.ResourceMapping = {
    "Deployment" = [_workload]
    "ConfigMap" = [_envConfig]
    "Service"   = [_service]
  }
