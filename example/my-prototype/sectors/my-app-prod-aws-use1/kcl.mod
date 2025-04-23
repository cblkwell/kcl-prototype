[package]
name = "my-app-prod-aws-use1"
edition = "v0.11.1"
version = "0.0.1"

[dependencies]
kcl-prototype = { path = "../../..", version = "0.0.1" }

[profile]
entries = ["../../base/base.k", "../../prod/prod.k", "main.k", "${kcl-prototype:KCL_MOD}/render/render.k"]
