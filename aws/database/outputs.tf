output "rds_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS endpoint for application connection"
}

output "rds_connection_string" {
  value       = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${var.db_name}"
  description = "PostgreSQL connection string"
  sensitive   = true
}
