import models.app

my_app = app.App {
  name = "my-app"
  image = "ghcr.io/my-app"
  deployments = {
    foo = {
      suffix = "foo"
    }
  }
}
