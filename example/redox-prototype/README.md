# redox-prototype

This is an example of an application deployed to two different sectors,
one in AWS and one in GCP. It shows how we can have inheritance between
various layers of the hierarchy and switch certain resources on or off,
or change how they are configured, based on their environment.

To run one of these examples, go to the sector you want to see the
manifests for and run:

```
kcl run -D image="ghcr.io/image"
```

This should generate a series of manifests for a variety of resources
based on the configurations in the base, prod, and sector directories.

You can look at the `kcl.mod` file in the sector directory to see how
it is handling inheritance:

```
[profile]
entries = ["../../base/base.k", "../../prod/prod.k", "main.k", "${kcl-prototype:KCL_MOD}/render/render.k"]
```

This section indicates that it takes the base configuration, then overlays
the prod configuration, then the sector configuration, and then sends the
combined configuration through to a renderer which turns that into the
actual Kubernetes manifests.
