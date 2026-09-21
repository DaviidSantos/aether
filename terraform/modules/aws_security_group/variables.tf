variable "name" {
  description = "Name of the security group. Must be unique within the VPC."
  type        = string
}

variable "description" {
  description = "Human-readable description of the security group. Required by AWS."
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "ID of the VPC where the security group will be created."
  type        = string
}

variable "ingress_rules" {
  type = list(object({
    description     = optional(string, "")
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = optional(list(string), [])
    security_groups = optional(list(string), [])
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    description = optional(string, "")
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = optional(list(string), [])
  }))
  default = []
}

variable "tags" {
  description = "Map of tags to apply to the security group."
  type        = map(string)
  default     = {}
}
