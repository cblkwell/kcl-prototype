import kcl_prototype.models.app

my_app: app.App {
  cloud_provider = "gcp"
  global_env_vars: {
    MY_GLOBAL_ENV: "sector-env"
  }
}
