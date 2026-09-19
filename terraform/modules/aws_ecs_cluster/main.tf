resource "aws_ecs_cluster" "this" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name     = var.cloud_watch_log_group_name
        cloud_watch_encryption_enabled = var.cloud_watch_encryption_enabled
      }
    }
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = length(var.capacity_provider_names) > 0 ? 1 : 0

  cluster_name       = var.cluster_name
  capacity_providers = var.capacity_provider_names

  default_capacity_provider_strategy {
    capacity_provider = var.capacity_provider_names[0]
    base              = var.capacity_provider_base
    weight            = var.capacity_provider_weight
  }
}
