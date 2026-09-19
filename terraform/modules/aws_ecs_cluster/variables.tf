variable "cluster_name" {
  type = string
}

variable "cloud_watch_log_group_name" {
  type = string
}

variable "cloud_watch_encryption_enabled" {
  type = bool
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "capacity_provider_names" {
  type = list(string)
}

variable "capacity_provider_base" {
  type = number
}

variable "capacity_provider_weight" {
  type = number
}
