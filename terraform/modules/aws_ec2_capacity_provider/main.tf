data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/${var.cpu_architecture}/recommended/image_id"
}

resource "aws_launch_template" "this" {
  name_prefix   = var.name_prefix
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = var.instance_type

  credit_specification {
    cpu_credits = "standard"
  }

  dynamic "instance_market_options" {
    for_each = var.instance_market_type == "spot" ? [1] : []
    content {
      market_type = "spot"

      dynamic "spot_options" {
        for_each = var.spot_max_price != null ? [1] : []
        content {
          max_price = var.spot_max_price
        }
      }
    }
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    set -euo pipefail
    dnf upgrade -y --releasever=2023 glib2 gnutls kernel policycoreutils
    echo "ECS_CLUSTER=${var.cluster_name}" >> /etc/ecs/ecs.config
    ${var.instance_market_type == "spot" ? "echo \"ECS_ENABLE_SPOT_INSTANCE_DRAINING=true\" >> /etc/ecs/ecs.config" : ""}
  EOT
  )

  iam_instance_profile {
    name = var.instance_profile_name
  }

  monitoring {
    enabled = var.monitoring_enabled
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.security_group_ids
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      iops                  = var.root_volume_iops
      throughput            = var.root_volume_throughput
      delete_on_termination = true
      encrypted             = var.root_volume_encrypted
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${var.name_prefix}-asg"
  min_size                  = var.instance_min
  max_size                  = var.instance_max
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = var.health_check_grace_period

  protect_from_scale_in = var.instance_market_type == "spot" ? true : false

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(var.tags, {
      "Name"             = var.name_prefix
      "AmazonECSManaged" = "true"
    })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes        = [desired_capacity]
    create_before_destroy = true
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = var.capacity_provider_name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = var.managed_termination_protection

    managed_scaling {
      status                    = var.managed_scaling_status
      target_capacity           = var.managed_scaling_target_capacity
      minimum_scaling_step_size = var.managed_scaling_min_step_size
      maximum_scaling_step_size = var.managed_scaling_max_step_size
      instance_warmup_period    = var.managed_scaling_instance_warmup
    }
  }
}
