import k8s.api.apps.v1 as appsv1
import k8s.api.core.v1 as corev1
import secrets_store_csi_driver.v1 as secretsv1
import konfig.models.kube.resource

import models.app
import models.protocol

mixin SecretProviderClassMixin for protocol.AppProtocol:
    if config.ref_secrets:
        kubernetes: resource.ResourceMapping {
            "SecretProviderClass" += [ secretsv1.SecretProviderClass {
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
            } for _i, _s in config.ref_secrets ]
        }
