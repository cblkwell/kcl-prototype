import kcl_prototype.models.app

_my_app = app.App {
  global_env_vars = {
    PROD_ENV = "prod-env"
  }
  deployments = {
    foo = {
      replicas = 12
    }
    baz = {
      suffix = "baz"
    }
  }
}
