resource "aws_ecs_service" "this" {
  cluster                            = var.aws_ecs_cluster_arn
  name                               = var.service_name
  task_definition                    = var.task_definition_arn
  desired_count                      = var.scheduling_strategy == "DAEMON" ? null : var.desired_count
  launch_type                        = length(var.capacity_provider_strategy) > 0 ? null : var.ecs_launch_type
  scheduling_strategy                = var.scheduling_strategy
  force_new_deployment               = true
  wait_for_steady_state              = var.scheduling_strategy == "DAEMON" ? false : true
  deployment_minimum_healthy_percent = var.scheduling_strategy == "DAEMON" ? 0 : var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.scheduling_strategy == "DAEMON" ? 100 : var.deployment_maximum_percent
  propagate_tags                     = "SERVICE"
  tags                               = var.tags

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      base              = lookup(capacity_provider_strategy.value, "base", 0)
      weight            = lookup(capacity_provider_strategy.value, "weight", 1)
    }
  }

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null && var.scheduling_strategy == "REPLICA" ? [1] : []
    content {
      container_name   = var.container_name
      container_port   = var.container_port
      target_group_arn = var.target_group_arn
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = var.scheduling_strategy == "REPLICA" ? [1] : []
    content {
      type  = "spread"
      field = "instanceId"
    }
  }

  dynamic "network_configuration" {
    for_each = var.network_mode == "awsvpc" ? [1] : []
    content {
      security_groups  = var.security_group_ids
      subnets          = var.subnet_ids
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "deployment_circuit_breaker" {
    for_each = [1] # Enable for both REPLICA and DAEMON
    content {
      enable   = true
      rollback = true
    }
  }

  timeouts {
    create = var.service_timeouts != null ? var.service_timeouts.create : null
    update = var.service_timeouts != null ? var.service_timeouts.update : null
    delete = var.service_timeouts != null ? var.service_timeouts.delete : null
  }
}
