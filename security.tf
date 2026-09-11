resource "aws_security_group" "rds" {
  name        = "${var.project}-rds"
  description = "RDS PostgreSQL: aceita 5432 dos nos do EKS e de quem tem o SG de cliente."
  vpc_id      = local.vpc_id

  # Sem egress de propósito: o RDS nunca inicia conexão.

  tags = { Name = "${var.project}-rds" }
}

# Crachá: nasce vazio e não protege nada — quem o anexa passa a alcançar o banco. É o que permite a
# a Lambda de autenticacao chegar no RDS sem criar regra dentro de um SG deste repositório.
resource "aws_security_group" "rds_client" {
  name        = "${var.project}-rds-client"
  description = "Cracha de acesso ao RDS: quem anexa este SG alcanca a instancia na 5432."
  vpc_id      = local.vpc_id

  tags = { Name = "${var.project}-rds-client" }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks_nodes" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = local.eks_node_sg_id
  ip_protocol                  = "tcp"
  from_port                    = local.db_port
  to_port                      = local.db_port
  description                  = "Pods do EKS (SG primario do cluster)"
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_client" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = aws_security_group.rds_client.id
  ip_protocol                  = "tcp"
  from_port                    = local.db_port
  to_port                      = local.db_port
  description                  = "Portadores do SG de cliente"
}

resource "aws_vpc_security_group_egress_rule" "client_to_rds" {
  security_group_id            = aws_security_group.rds_client.id
  referenced_security_group_id = aws_security_group.rds.id
  ip_protocol                  = "tcp"
  from_port                    = local.db_port
  to_port                      = local.db_port
  description                  = "Saida para o RDS"
}
