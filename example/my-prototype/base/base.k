import kcl_prototype.models.app

my_app = app.App {
  name = "my-app"
  global_env_vars = {
    MY_GLOBAL_ENV = "global-env"
  }
  ref_secrets = [
    "my-app-secret"
    "foo-secret"
  ]
  authorized_callers = [
    "broken-app"
  ]
  deployments = {
    foo = {
      suffix = "foo"
      service = True
      env_vars: {
        MY_DEPLOY_ENV = "foo-env"
      }
      # This cannot generate new secretproviderclasses.
      ref_secrets = [
        "foo-secret"
      ]
    }
    bar = {
      suffix = "bar"
      replicas = 3
      env_vars: {
        MY_DEPLOY_ENV = "bar-env"
      }
    }
  }
}
