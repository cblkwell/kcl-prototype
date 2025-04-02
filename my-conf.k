import models.app

my_app = app.App {
  name = "my-app"
  image = "ghcr.io/my-app"
  global_env_vars = {
    MY_GLOBAL_ENV = "global-env"
  }
  ref_secrets = [
    "my-app-secret"
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
