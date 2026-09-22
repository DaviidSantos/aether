variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "backend_ecr_repository_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "log_retention_days" {
  type    = number
  default = 1
}

variable "image_uri" {
  type    = string
  default = "placeholder"
}

variable "ingress_cidr_blocks" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "cpu_architecture" {
  type    = string
  default = "arm64"
}

variable "instance_max" {
  type    = number
  default = 1
}

variable "container_cpu" {
  description = "Container vCPU units. 1024 = 1 vCPU. 256 = 0.25 vCPU."
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Container memory in MiB."
  type        = number
  default     = 512
}

variable "volume_name" {
  description = "Name of the volume shared between the task definition and the EC2 host."
  type        = string
  default     = "data"
}

variable "volume_mount_path" {
  description = "Path inside the container (and on the host) where the volume is mounted."
  type        = string
  default     = "/mnt/data"
}
