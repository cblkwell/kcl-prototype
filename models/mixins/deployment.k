import k8s.api.apps.v1 as appsv1
import k8s.api.core.v1 as corev1
import konfig.models.kube.resource

import models.app
import models.protocol

mixin DeploymentMixin for protocol.AppProtocol:
    if config.deployments:
        kubernetes: resource.ResourceMapping {
            "Deployment" += [ appsv1.Deployment {
                metadata.name = "${config.name}-${_d.suffix}"
                metadata.namespace = "${config.namespace}"
                spec = {
                    replicas = _d.replicas
                    selector = {
                        matchLabels = {
                            "app.kubernetes.io/name" = "${config.name}-${_d.suffix}"
                        }
                    }
                    template.spec = { 
                        serviceAccountName = "${config.name}-default"
                        containers = [
                            {
                                name = "${config.name}-${_d.suffix}"
                                image = config.image
                                command = [ "./runt" ]
                                env = [{
                                    name = "MY_POD_NAME"
                                    valueFrom = {
                                        fieldRef = {
                                            apiVersion = "v1"
                                            fieldPath = "metadata.name"
                                        }
                                     }
                                }, {
                                    name = "MY_POD_NAMESPACE"
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
                                        name = "${config.name}-global-env"
                                    }
                                }, {
                                    configMapRef = {
                                        name = "${config.name}-${_d.suffix}-env"
                                    }   
                                }]
                                resources = _d.resources
                                ports = _d.ports
                                volumeMounts = [ corev1.VolumeMount {
                                    mountPath = "/mnt/secrets/${_s.metadata.name}"
                                    name = _s.metadata.name
                                    readOnly = True
                                } for _i, _s in secretProviderClasses ]
                            }
                        ]
                        volumes = [ corev1.Volume {
                            csi = {
                                driver = "secrets-store.csi.k8s.io"
                                readOnly = True
                                volumeAttributes = {
                                   secretProviderClass = _s.metadata.name
                                }
                            }
                            name = _s.metadata.name
                        } for _i, _s in secretProviderClasses ]
                    }
                }
            } for _k, _d in config.deployments]

            "ConfigMap" += [ corev1.ConfigMap {
                metadata: {
                    name: "${config.name}-${_d.suffix}-env"
                    namespace: config.namespace
                }
                data = _d.env_vars
            } for _k, _d in config.deployments if _d.env_vars ]

            "Service" += [ corev1.Service {
                metadata: {
                    name = "${config.name}-${_d.suffix}"
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
                        "app.kubernetes.io/component" = _d.suffix
                        "app.kubernetes.io/part-of" = config.name
                    }
                }
            } for _k, _d in config.deployments if _d.service ]

        #    "SecretProviderClass" += [
        #      app.RefSecret(_s, config.namespace).secret for _i, _s in _d.ref_secrets
        #    ]    
        }
