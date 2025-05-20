variable "db_name" {
  type    = string
  default = "stackslurper"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "subnets" {
  description = "Subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "backend_security_group_id" {
  description = "Security group ID for allowing RDS access from backend"
  type        = string
}
