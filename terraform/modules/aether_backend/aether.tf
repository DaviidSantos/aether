module "backend_ecr_repository" {
  source = "../aws_ecr_repository"

  name = var.backend_ecr_repository_name
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"]
  }
}

locals {
  common_tags = {
    Project     = "aether"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  cluster_name = "aether-${var.environment}-cluster"
  service_name = "aether-${var.environment}-backend"
  spot_cp_name = "aether-${var.environment}-spot-cp"

  container_name = "aether-backend"
  container_port = 3000
  image_uri      = var.image_uri
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${local.cluster_name}"
  retention_in_days = var.log_retention_days
  tags              = local.common_tags
}

data "aws_iam_policy_document" "ecs_instance_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance" {
  name               = "${local.cluster_name}-ecs-instance"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ecs" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${local.cluster_name}-ecs-instance"
  role = aws_iam_role.ecs_instance.name
}

module "ecs_sg" {
  source = "../aws_security_group"

  name        = "${local.cluster_name}-ecs-sg"
  description = "Security group for ECS tasks (${local.service_name})"
  vpc_id      = data.aws_vpc.default.id

  ingress_rules = [
    {
      description = "Application port"
      from_port   = local.container_port
      to_port     = local.container_port
      protocol    = "tcp"
      cidr_blocks = var.ingress_cidr_blocks
    },
  ]

  egress_rules = [
    {
      description = "All outbound (ECR pull, AWS APIs, external services)"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  tags = local.common_tags
}

module "ec2_capacity_provider" {
  source = "../aws_ec2_capacity_provider"

  name_prefix            = "${local.cluster_name}-spot"
  capacity_provider_name = local.spot_cp_name
  cluster_name           = local.cluster_name

  instance_type        = var.instance_type
  cpu_architecture     = var.cpu_architecture
  instance_market_type = "spot"
  spot_max_price       = null

  instance_min                    = 0
  instance_max                    = var.instance_max
  health_check_grace_period       = 120
  managed_termination_protection  = "ENABLED"
  managed_scaling_status          = "ENABLED"
  managed_scaling_target_capacity = 100
  managed_scaling_min_step_size   = 1
  managed_scaling_max_step_size   = var.instance_max
  managed_scaling_instance_warmup = 60

  subnet_ids                  = data.aws_subnets.default.ids
  security_group_ids          = [module.ecs_sg.security_group_id]
  associate_public_ip_address = true

  root_volume_size       = 30
  root_volume_type       = "gp3"
  root_volume_iops       = 3000
  root_volume_throughput = 125
  root_volume_encrypted  = true

  monitoring_enabled    = false
  instance_profile_name = aws_iam_instance_profile.ecs_instance.name
  tags                  = local.common_tags
}

module "ecs_cluster" {
  source = "../aws_ecs_cluster"

  cluster_name                   = local.cluster_name
  cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs.name
  cloud_watch_encryption_enabled = false

  capacity_provider_names  = [module.ec2_capacity_provider.capacity_provider_name]
  capacity_provider_base   = 0
  capacity_provider_weight = 1

  tags = local.common_tags
}

module "ecs_task_definition" {
  source = "../aws_ecs_taskdef"

  family          = "${local.cluster_name}-backend"
  task_definition = "app.json.tmpl"

  task_definition_variables = {
    service_name         = local.container_name
    image                = local.image_uri
    cpu_limit            = var.container_cpu
    memory_limit         = var.container_memory
    aws_region           = var.aws_region
    environment          = var.environment
    container_port       = local.container_port
    volume_name          = var.volume_name
    mount_container_path = var.volume_mount_path
    cw_log_group         = aws_cloudwatch_log_group.ecs.name
  }

  ecs_launch_type = "EC2"
  network_mode    = "bridge"
  cpu_limit       = null
  memory_limit    = null
  pid_mode        = null

  volumes = [
    {
      name      = var.volume_name
      host_path = var.volume_mount_path
    },
  ]
}

module "ecs_service" {
  source = "../aws_ecs_service"

  aws_ecs_cluster_arn = module.ecs_cluster.cluster_arn
  service_name        = local.service_name
  task_definition_arn = module.ecs_task_definition.task_definition_arn

  scheduling_strategy = "REPLICA"
  desired_count       = 1
  ecs_launch_type     = "EC2"

  capacity_provider_strategy = [
    {
      capacity_provider = module.ec2_capacity_provider.capacity_provider_name
      base              = 0
      weight            = 1
    },
  ]

  target_group_arn = null
  container_name   = local.container_name
  container_port   = local.container_port

  network_mode       = "bridge"
  security_group_ids = [module.ecs_sg.security_group_id]
  subnet_ids         = data.aws_subnets.default.ids
  assign_public_ip   = true

  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  service_timeouts = {
    create = "20m"
    update = "20m"
    delete = "20m"
  }

  tags = local.common_tags
}

module "drive_s3_bucket" {
  source = "../aws_s3"

  s3_bucket_name = "drive-s3-bucket"
}
