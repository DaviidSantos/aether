variable "family" {
  description = "Family name for the ECS task definition"
  type        = string
}

variable "cpu_limit" {
  description = "CPU units for the task definition"
  type        = number
}

variable "memory_limit" {
  description = "Memory (MiB) for the task definition"
  type        = number
}

variable "ecs_launch_type" {
  description = "ECS launch type (e.g., EC2 or FARGATE)"
  type        = string
}

variable "task_definition" {
  description = "The task definition template file name under definitions/ (e.g., app.json.tmpl)"
  type        = string
}

variable "task_definition_variables" {
  description = "Variables to pass to the task definition template"
  type        = map(string)
}

variable "network_mode" {
  description = "The Docker networking mode to use for the containers in the task"
  type        = string
  default     = "bridge"
}

variable "volumes" {
  description = "List of volume definitions for the task. Each volume should have a name and host_path."
  type = list(object({
    name      = string
    host_path = string
  }))
  default = []
}

variable "pid_mode" {
  description = "The process namespace to use for the containers in the task"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role used to fetch secrets and pull images."
  type        = string
  default     = null
}
