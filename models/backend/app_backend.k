import k8s.api.apps.v1 as appsv1
import k8s.api.core.v1 as corev1
import konfig.models.kube.resource
import models.app

schema AppBackend[inputConfig: app.App]:
  config: App = inputConfig
  
  # Construct app manifests
  kubernetes: resource.ResourceMapping {
    ServiceAccount = corev1.ServiceAccount {
      metadata: {
        name = "${config.name}-default"
        namespace = "services"
      }
    }
  }
