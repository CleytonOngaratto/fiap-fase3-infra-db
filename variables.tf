variable "region" {
  description = "Região AWS. O Learner Lab só libera us-east-1 e us-west-2."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Prefixo de nome e valor da tag Project."
  type        = string
  default     = "fiap-fase3"
}

variable "engine_version" {
  description = "Versão do PostgreSQL. Prefixo de major basta; 16 casa com o docker-compose da app."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "Classe da instância. O lab só libera micro/small/medium."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Storage em GB. 20 é o mínimo do gp2."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Teto do storage autoscaling. 0 desliga — o autoscaling sobe sozinho e NÃO desce."
  type        = number
  default     = 0
}

variable "backup_retention_period" {
  description = "Dias de retenção do backup automático. 1 é o mínimo que o mantém ligado; 0 desliga."
  type        = number
  default     = 1
}

variable "db_name" {
  description = "Banco criado no boot. Tem que casar com a app (Quarkus/Flyway)."
  type        = string
  default     = "oficina_db"
}

variable "db_username" {
  description = "Master user. Tem que casar com a app; como é dono do banco, o Flyway escreve no schema public."
  type        = string
  default     = "postgres"
}

variable "multi_az" {
  description = "Standby em outra AZ. Dobra o custo e o ambiente é único."
  type        = bool
  default     = false
}

variable "storage_encrypted" {
  description = "Criptografia em repouso com a chave gerenciada aws/rds (o lab não permite criar chave própria)."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Trava contra exclusão. Com true o `terraform destroy` FALHA."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Pula o snapshot final. Com false o snapshot sobrevive ao destroy e segue cobrando."
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Aplica alterações na hora; a janela de manutenção cairia fora da sessão de ~4h do lab."
  type        = bool
  default     = true
}
