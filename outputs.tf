output "db_identifier" {
  description = "Identificador da instância."
  value       = aws_db_instance.main.identifier
}

output "db_endpoint" {
  description = "Hostname da instância, sem a porta."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "Porta da instância."
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Banco criado no boot."
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Master user."
  value       = aws_db_instance.main.username
}

output "jdbc_url" {
  description = "URL para o datasource do Quarkus. A senha vai à parte, pelo SSM."
  value       = "jdbc:postgresql://${aws_db_instance.main.address}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
}

output "rds_security_group_id" {
  description = "SG anexado à instância."
  value       = aws_security_group.rds.id
}

output "rds_client_security_group_id" {
  description = "SG de cliente — anexe-o a qualquer workload que precise falar com o banco."
  value       = aws_security_group.rds_client.id
}

output "password_ssm_parameter" {
  description = "Onde buscar a senha: aws ssm get-parameter --name <isto> --with-decryption"
  value       = aws_ssm_parameter.password.name
}
