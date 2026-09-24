variable "name_prefix" {
  type = string
}

variable "subnet_ids" {
  description = "Two or more subnets in different AZs for the DB subnet group."
  type        = list(string)
}

variable "security_group_id" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_name" {
  type    = string
  default = "aether"
}

variable "db_username" {
  type    = string
  default = "aether_admin"
}

variable "tags" {
  type    = map(string)
  default = {}
}
