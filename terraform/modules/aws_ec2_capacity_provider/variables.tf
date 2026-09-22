variable "name_prefix" {
  description = "Name prefix for the launch template and ASG (e.g., 'ecr-cloud-proxy-devl-ecs')"
  type        = string
}

variable "cluster_name" {
  description = "ECS cluster name to register instances with"
  type        = string
}

variable "capacity_provider_name" {
  description = "Name of the ECS capacity provider"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_min" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
}

variable "instance_max" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
}

variable "instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

variable "monitoring_enabled" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "Security group IDs for EC2 instances"
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnet IDs for the ASG"
  type        = list(string)
}

variable "health_check_grace_period" {
  description = "Health check grace period for the ASG"
  type        = number
  default     = 300
}

variable "root_volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 30
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_iops" {
  description = "Root volume IOPS (gp3/io1/io2 only)"
  type        = number
  default     = null
}

variable "root_volume_throughput" {
  description = "Root volume throughput in MiB/s (gp3 only)"
  type        = number
  default     = null
}

variable "root_volume_encrypted" {
  description = "Whether the root volume is encrypted"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to EC2 instances and volumes"
  type        = map(string)
  default     = {}
}

variable "managed_termination_protection" {
  description = "Managed termination protection setting"
  type        = string
  default     = "DISABLED"
}

variable "managed_scaling_status" {
  description = "Managed scaling status"
  type        = string
  default     = "ENABLED"
}

variable "managed_scaling_target_capacity" {
  description = "Target capacity percentage for managed scaling"
  type        = number
  default     = 100
}

variable "managed_scaling_min_step_size" {
  description = "Minimum scaling step size"
  type        = number
  default     = 1
}

variable "managed_scaling_max_step_size" {
  description = "Maximum scaling step size"
  type        = number
  default     = 1000
}

variable "managed_scaling_instance_warmup" {
  description = "Instance warmup period in seconds"
  type        = number
  default     = 300
}

variable "cpu_architecture" {
  type = string
}

variable "instance_market_type" {
  description = "EC2 market type. Use \"spot\" for cost savings (interruptible) or \"on-demand\" for stability."
  type        = string
  default     = "spot"

  validation {
    condition     = contains(["spot", "on-demand"], var.instance_market_type)
    error_message = "instance_market_type must be either \"spot\" or \"on-demand\"."
  }
}

variable "spot_max_price" {
  description = "Maximum hourly price for Spot instances. Leave null to pay the current Spot market price (recommended)."
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}
