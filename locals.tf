locals {
  identifier = "${var.project}-postgres"

  tags = {
    Project   = var.project
    ManagedBy = "terraform"
    Repo      = "fiap-fase3-infra-db"
  }

  # Local, e não `aws_db_instance.main.port`: as regras de SG precisam da porta antes da instância
  # existir, e referenciá-la de lá faria um ciclo.
  db_port = 5432

  vpc_id          = data.aws_ssm_parameter.vpc_id.value
  private_subnets = split(",", data.aws_ssm_parameter.private_subnets.value) # StringList vem como CSV
  eks_node_sg_id  = data.aws_ssm_parameter.eks_node_sg_id.value
}
