import manifests
import konfig.models.kube.resource

import models.backend
import models.app

manifestsResourceMap = lambda resource_map: {str: []} {
  _resource_list = [res_list for _, res_list in resource_map]
  _resource_list = sum(_resource_list, [])
  manifests.yaml_stream(_resource_list)
}

_frontendInstances = [inst for inst in app.App.instances()]
_backendInstances = [backend.AppBackend(inst) for inst in _frontendInstances]

_resource_array: [resource.ResourceMapping] = [
  _inst?.kubernetes for _inst in _backendInstances if _inst?.kubernetes
]

_resource_map: resource.ResourceMapping = {
  _kind += [r for key, r in _res] \
    for _index, _res_map in _resource_array \
      for _kind, _res in _res_map
}

_output = { 
    _kind: [_resource for _resource in _res] \
        for _kind, _res in _resource_map
}

manifestsResourceMap(_output)
