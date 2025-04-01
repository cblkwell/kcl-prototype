import models.app

my_app = app.App {
  name = "my-app"
  image = "ghcr.io/my-app"
  global_env_vars = {
    MY_GLOBAL_ENV = "global-env"
  }
  deployments = {
    foo = {
      suffix = "foo"
      service = True
      env_vars: {
        MY_DEPLOY_ENV = "foo-env"
      }
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
