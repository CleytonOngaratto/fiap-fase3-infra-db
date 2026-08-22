<#
.SYNOPSIS
    GATE — roda ANTES de `terraform apply`. Custa segundos e evita um apply de 10 minutos.

.DESCRIPTION
    Valida o que este repositório assume do Learner Lab: sessão viva, contrato do repo 2 publicado,
    SecureString funcionando (onde a senha do RDS vai morar), chave aws/rds disponível (de que a
    criptografia em repouso depende) e a combinação engine/classe ofertada na região.

.EXAMPLE
    .\scripts\preflight.ps1
#>

[CmdletBinding()]
param(
    [string]$Region = "us-east-1",
    [string]$EngineVersion = "16",
    [string]$InstanceClass = "db.t3.micro"
)

$ErrorActionPreference = "Continue"
$script:Failed = $false

function Write-Head($text) { Write-Host "`n=== $text ===" -ForegroundColor Cyan }
function Write-Ok($text) { Write-Host "  [OK]   $text" -ForegroundColor Green }
function Write-Warn2($text) { Write-Host "  [WARN] $text" -ForegroundColor Yellow }
function Write-Fail($text) { Write-Host "  [FAIL] $text" -ForegroundColor Red; $script:Failed = $true }

Write-Head "1. Sessao AWS"
$identity = aws sts get-caller-identity --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $null -eq $identity) {
    Write-Fail "Sem credenciais validas. A sessao do Learner Lab dura ~4h: abra o lab, copie o bloco 'AWS Details' para ~/.aws/credentials e rode de novo."
    exit 1
}
Write-Ok "Conta $($identity.Account) · $($identity.Arn)"

Write-Head "2. Contrato de entrada (repo 2 aplicado?)"
$required = @("/fase3/vpc/id", "/fase3/vpc/private-subnets", "/fase3/eks/node-sg-id")
foreach ($name in $required) {
    $value = aws ssm get-parameter --name $name --region $Region --query "Parameter.Value" --output text
    if ($LASTEXITCODE -eq 0 -and $value) { Write-Ok "$name = $value" }
    else { Write-Fail "$name AUSENTE — aplique o repo fiap-fase3-infra-k8s primeiro (ordem 2 -> 3 -> 4 -> 1)." }
}

Write-Head "3. SecureString (onde a senha do RDS vai morar)"

# O preflight do repo 2 provou `String`. SecureString depende da chave gerenciada alias/aws/ssm, e o
# lab restringe KMS.
$null = aws ssm put-parameter --name "/fase3/preflight-db" --value "ok" --type SecureString --overwrite --region $Region
if ($LASTEXITCODE -eq 0) {
    $back = aws ssm get-parameter --name "/fase3/preflight-db" --with-decryption --region $Region --query "Parameter.Value" --output text
    if ($LASTEXITCODE -eq 0 -and $back -eq "ok") { Write-Ok "put/get com --with-decryption funcionam" }
    else { Write-Fail "PutParameter passou mas a leitura decifrada falhou — a senha ficaria ilegivel para a app." }
    $null = aws ssm delete-parameter --name "/fase3/preflight-db" --region $Region
}
else {
    Write-Fail "SecureString negado. Sem isso a senha do RDS nao tem onde ser publicada — resolva ANTES do apply."
}

Write-Head "4. Criptografia em repouso (storage_encrypted)"
$null = aws kms describe-key --key-id alias/aws/rds --region $Region
if ($LASTEXITCODE -eq 0) { Write-Ok "alias/aws/rds acessivel" }
else { Write-Warn2 "alias/aws/rds indisponivel — se o apply falhar na criacao, use storage_encrypted = false no tfvars." }

Write-Head "5. Engine e classe ofertadas na regiao"

# describe-db-engine-versions aceita prefixo de major (o mesmo que o Terraform usa); ja o
# describe-orderable-db-instance-options exige a versao COMPLETA e, com prefixo, responde
# "Engine version is not a valid full version" — que soaria como classe indisponivel.
$fullVersion = aws rds describe-db-engine-versions --engine postgres --engine-version $EngineVersion `
    --region $Region --query "DBEngineVersions[-1].EngineVersion" --output text
if ($LASTEXITCODE -ne 0 -or -not $fullVersion -or $fullVersion -eq "None") {
    Write-Fail "PostgreSQL $EngineVersion nao ofertado em $Region — ajuste engine_version."
}
else {
    Write-Ok "PostgreSQL $EngineVersion disponivel — minor mais recente: $fullVersion"

    $classes = aws rds describe-orderable-db-instance-options --engine postgres --engine-version $fullVersion `
        --db-instance-class $InstanceClass --region $Region --query "length(OrderableDBInstanceOptions)" --output text
    if ($LASTEXITCODE -eq 0 -and [int]$classes -gt 0) { Write-Ok "$InstanceClass ofertada para PostgreSQL $fullVersion" }
    else { Write-Fail "$InstanceClass nao ofertada para PostgreSQL $fullVersion — tente db.t3.small." }
}

Write-Head "6. Ja existe RDS de pe?"
$instances = aws rds describe-db-instances --region $Region --query "DBInstances[].DBInstanceIdentifier" --output json | ConvertFrom-Json
if ($LASTEXITCODE -eq 0 -and $instances.Count -gt 0) {
    Write-Warn2 "Instancia(s) na conta: $($instances -join ', ') — se for da sessao anterior, esta faturando desde entao."
}
else {
    Write-Ok "Nenhuma instancia RDS na conta"
}

Write-Head "7. backend.hcl"
$backendPath = Join-Path (Split-Path $PSScriptRoot -Parent) "backend.hcl"
if (Test-Path $backendPath) {
    Write-Ok "backend.hcl ja existe"
}
else {
    Write-Warn2 "backend.hcl ausente. Crie com o conteudo abaixo (o bucket veio do bootstrap do repo 2):"
    Write-Host ""
    Write-Host "bucket       = `"fiap-fase3-tfstate-$($identity.Account)`"" -ForegroundColor DarkGray
    Write-Host "key          = `"infra-db/terraform.tfstate`"" -ForegroundColor DarkGray
    Write-Host "region       = `"$Region`"" -ForegroundColor DarkGray
    Write-Host "use_lockfile = true" -ForegroundColor DarkGray
    Write-Host "encrypt      = true" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "  LEMBRETE: parar a instancia NAO substitui o destroy — o lab religa RDS parado em 7 dias." -ForegroundColor Yellow

Write-Host ""
if ($script:Failed) {
    Write-Host "PREFLIGHT REPROVADO — resolva os [FAIL] acima antes do apply." -ForegroundColor Red
    exit 1
}
Write-Host "PREFLIGHT OK — pode seguir para terraform init/plan/apply." -ForegroundColor Green
