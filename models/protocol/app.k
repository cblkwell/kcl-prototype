import konfig.models.kube.resource
import secrets_store_csi_driver.v1 as secretsv1

import models.app

protocol AppProtocol:
    config: app.App
    kubernetes: resource.ResourceMapping
    secretProviderClasses: [secretsv1.SecretProviderClass]
