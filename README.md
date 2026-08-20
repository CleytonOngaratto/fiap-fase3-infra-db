# fiap-fase3-infra-db — RDS PostgreSQL (Terraform)

Repositório **3 de 4** do Tech Challenge Fase 3 (oficina mecânica → operação corporativa em nuvem).

```
2 · infra-k8s  ──►  3 · infra-db  ──►  4 · app  ──►  1 · auth-serverless
   VPC/EKS/ECR      (você está aqui)   Quarkus/EKS    Lambda + API Gateway
```

O que este repo provisiona: **instância RDS PostgreSQL** gerenciada, seu **DB subnet group** nas
subnets privadas da VPC e o **security group** que libera os nós do EKS e a Lambda — publicando o
endpoint no **SSM Parameter Store** para os repositórios 4 e 1 consumirem.

Toda a rede vem do repositório 2 via SSM (`/fase3/vpc/*`, `/fase3/eks/node-sg-id`): **nenhum ID de
VPC, subnet ou security group é hardcodado aqui.**

> 🚧 Repositório recém-inicializado. O Terraform, o pipeline e a documentação completa entram pelo
> primeiro pull request.
