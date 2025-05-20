# This defines which subnets your RDS database is allowed to use.
# Even though this is a single-AZ instance, AWS still requires a subnet group.
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "stackslurper-rds-subnet-group"
  subnet_ids = var.subnets

  tags = {
    Name = "Stackslurper RDS subnet group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "stackslurper-db"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.5"
  instance_class         = "db.t3.micro" # ✅ Free Tier eligible in most regions
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [var.backend_security_group_id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  multi_az               = false
}
