variable "aws_ecs_cluster_arn" {
  type = string
}

variable "service_name" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "desired_count" {
  type = number
}


variable "ecs_launch_type" {
  description = "ECS launch type (e.g., EC2 or FARGATE)"
  type        = string
}

variable "capacity_provider_strategy" {
  description = "Capacity provider strategy to use for the service. When set, launch_type is not used."
  type = list(object({
    capacity_provider = string
    base              = optional(number, 0)
    weight            = optional(number, 1)
  }))
  default = []
}


variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks during a deployment"
  type        = number
  # keep at least half of desired count running so a deployment never drops to zero tasks
  default = 50
}

variable "deployment_maximum_percent" {
  description = "Upper limit on the number of running tasks during a deployment"
  type        = number
  default     = 100
}

variable "container_name" {
  description = "Container name for the load balancer target"
  type        = string
  default     = null
}

variable "container_port" {
  description = "Container port exposed by the task"
  type        = number
  default     = null
}

variable "target_group_arn" {
  description = "Target group ARN for the service load balancer. Set to null to skip load balancer."
  type        = string
  default     = null
}

variable "network_mode" {
  description = "The Docker networking mode used by the task (awsvpc, bridge, host, none)"
  type        = string
  default     = "bridge"
}

variable "security_group_ids" {
  description = "Security group IDs for the service (only used when network_mode = awsvpc)"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnet IDs used by the service network configuration (only used when network_mode = awsvpc)"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP in the service network configuration"
  type        = bool
  default     = false
}

variable "service_timeouts" {
  description = "Custom timeouts for the ECS service. Null to use Terraform defaults."
  type = object({
    create = string
    update = string
    delete = string
  })
  default = null
}

variable "scheduling_strategy" {
  description = "Scheduling strategy for the service (REPLICA or DAEMON)"
  type        = string
  default     = "REPLICA"
  validation {
    condition     = contains(["REPLICA", "DAEMON"], var.scheduling_strategy)
    error_message = "Scheduling strategy must be either REPLICA or DAEMON."
  }
}

variable "tags" {
  description = "Tags to apply to the ECS service."
  type        = map(string)
  default     = {}
}
