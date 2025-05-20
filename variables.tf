variable "dev_ssh_keys" {
  description = "List of developer public SSH keys"
  type        = list(string)
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_name" {
  type    = string
  default = "stackslurper"
}
