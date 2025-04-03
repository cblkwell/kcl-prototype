To install kcl, you can run `brew install kcl-lang/tap/kcl`.

To generate a set of manifests, run this from the root of the repo:

```
kcl my-conf.k render/render.k -D image="ghcr.io/image" -D cloud="gcp"
```
