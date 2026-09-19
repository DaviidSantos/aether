terraform {
  source = "../../modules/aether_backend"

  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=10m"]
  }
}

remote_state {
  backend = "s3"
  config = {
    bucket       = "terragrunt-909891185654-us-east-1-statefiles"
    key          = "dwvidswntos/aether.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}