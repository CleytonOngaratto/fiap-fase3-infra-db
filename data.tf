data "aws_ssm_parameter" "vpc_id" {
  name = "/fase3/vpc/id"
}

data "aws_ssm_parameter" "private_subnets" {
  name = "/fase3/vpc/private-subnets"
}

# É o cluster_security_group_id: node group gerenciado sem launch template não tem SG próprio, os
# nós herdam o do cluster. Outro SG aqui deixa os pods em timeout, com cara de problema de rede.
data "aws_ssm_parameter" "eks_node_sg_id" {
  name = "/fase3/eks/node-sg-id"
}
