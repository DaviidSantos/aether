resource "aws_ecs_task_definition" "this" {
  family             = var.family
  execution_role_arn = var.execution_role_arn
  container_definitions = templatefile(
    "${path.module}/definitions/${var.task_definition}",
    var.task_definition_variables
  )
  requires_compatibilities = [var.ecs_launch_type]
  network_mode             = var.network_mode
  memory                   = var.memory_limit
  cpu                      = var.cpu_limit
  pid_mode                 = var.pid_mode

  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = volume.value.host_path
    }
  }
}
