import konfig.models.kube.resource

import models.app

protocol AppProtocol:
    config: app.App
    kubernetes: resource.ResourceMapping
