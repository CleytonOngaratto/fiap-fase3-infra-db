# `.address` e não `.endpoint`: o atributo endpoint já vem como "host:5432" e, ao lado do parâmetro
# de porta, produziria "host:5432:5432" nas URLs montadas pelos consumidores.
resource "aws_ssm_parameter" "endpoint" {
  name  = "/fase3/rds/endpoint"
  type  = "String"
  value = aws_db_instance.main.address
}

resource "aws_ssm_parameter" "port" {
  name  = "/fase3/rds/port"
  type  = "String"
  value = tostring(aws_db_instance.main.port)
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/fase3/rds/db-name"
  type  = "String"
  value = aws_db_instance.main.db_name
}

resource "aws_ssm_parameter" "username" {
  name  = "/fase3/rds/username"
  type  = "String"
  value = aws_db_instance.main.username
}

resource "aws_ssm_parameter" "password" {
  name  = "/fase3/rds/password"
  type  = "SecureString"
  value = random_password.master.result
}

resource "aws_ssm_parameter" "client_sg_id" {
  name  = "/fase3/rds/client-sg-id"
  type  = "String"
  value = aws_security_group.rds_client.id
}
