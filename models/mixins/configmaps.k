import k8s.api.core.v1
import konfig.models.kube.resource

mixin GlobalEnvConfigMapMixin:
   globalconfigmap: {str:} = {
       metadata: {
           name = "${name}-global-env"
           namespace = namespace
       }
       data = global_env_vars
   }

mixin DeployEnvConfigMapMixin:
    if config.env_vars:
        kubernetes: resource.ResourceMapping {
            ConfigMap = [v1.ConfigMap {
                metadata: {
                    name: "testAppName-${config.suffix}-env"
                    namespace: "services"
                }
                data = config.env_vars
            }] 
        }
