import manifests
import konfig.models.kube.resource

import models.backend

manifestsResourceMap = lambda resource_map: {str: []} {
    # Convert resource map into a resource list
    _resource_list = [res_list for _, res_list in resource_map]
    # Use `sum` function to flatten the resource list
    _resource_list = sum(_resource_list, [])
    manifests.yaml_stream(_resource_list)
}

_frontendInstances = [inst for inst in app.Deploy.instances()]
backendInstances = [backend.DeployBackend(inst) for inst in _frontendInstances]

resource_array: [resource.ResourceMapping] = [
  _inst?.kubernetes for _inst in backendInstances if _inst?.kubernetes
]

resources = { kind = res_list for kind, res_list in res \
                for res in resource_array }

#_output = { 
#    _kind: [_resource for _resource in _res] \
#        for _kind, _res in _resource_map
#}
#manifestsResourceMap(_output)
