# import k8s.api.apps.v1 as appsv1
# import k8s.api.core.v1 as corev1
# import k8s.api.secrets-store-csi-driver.v1 as secretsv1
# import konfig.models.kube.resource

# import models.app
# import models.protocol

# mixin SecretProviderClassMixin for protocol.AppProtocol:
  #  if config.deployments:

      #  kubernetes: resource.ResourceMapping {
        #   "SecretProviderClass" += [ secretsv1.SecretProviderClass {
       #         metadata.name = 
