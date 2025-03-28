import manifests
import k8s.api.core.v1 as corev1
import k8s.api.apps.v1 as appsv1

import models.app

kubernetesRender = lambda a: app.App {
  serviceaccount = corev1.ServiceAccount {
    metadata.name = "${a.name}-default"
    metadata.namespace = "services"
  }

  global_env = corev1.ConfigMap {
    metadata.name = "${a.name}-global-env"
    metadata.namespace = "services"
    data = a.global_env_vars
  }

  service_secret = "service/${a.name}"

  deployments = [ appsv1.Deployment {
    metadata.name = "${a.name}-${d.suffix}"
    metadata.namespace = "services"
    spec = {
      replicas = d.replicas
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "${a.name}-${d.suffix}"
        }
      }
      template.spec.containers = [
        {
          name = a.name
          image = a.image
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
              name = "${a.name}-global-env"
            }
          }]
          resources = d.resources
          ports = d.ports
        }
      ]
    }
  } for _ , d in a.deployments ]

  [
    serviceaccount,
    global_env,
    if a.deployments: deployments
  ]
}

manifests.yaml_stream(sum([kubernetesRender(a) for a in app.App.instances()], []))
