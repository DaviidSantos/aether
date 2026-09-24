variable "secret_name" {
  type = string
}

variable "description" {
  type = string
}

variable "secret" {
  type      = string
  sensitive = true
}
