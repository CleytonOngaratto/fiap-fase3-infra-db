resource "aws_db_subnet_group" "main" {
  name        = "${var.project}-db"
  description = "Subnets privadas elegiveis para a instancia (o RDS exige pelo menos duas AZs)."
  subnet_ids  = local.private_subnets

  tags = { Name = "${var.project}-db" }
}

resource "random_password" "master" {
  length = 24

  # O RDS recusa `/`, `@`, `"` e espaço; o resto ainda precisa atravessar URI e shell sem escaping.
  override_special = "*()-_=+[]{}"
}

resource "aws_db_instance" "main" {
  identifier = local.identifier

  engine         = "postgres"
  engine_version = var.engine_version

  # Sem isto o prefixo de major viraria diff a cada plan (a AWS resolve para 16.x).
  auto_minor_version_upgrade = true

  # Extended support cobra por vCPU-hora — mais que a própria instância.
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"

  instance_class = var.instance_class
  db_name        = var.db_name
  username       = var.db_username
  password       = random_password.master.result
  port           = local.db_port

  storage_type          = "gp2" # o lab não libera gp3
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot   = true

  # Bloqueados no Learner Lab; o enhanced monitoring ainda exigiria criar uma IAM role.
  monitoring_interval          = 0
  performance_insights_enabled = false

  apply_immediately   = var.apply_immediately
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  tags = { Name = local.identifier }
}
