Param(
  [string]$TargetDir = "$env:USERPROFILE\.trae\mcp",
  [string]$NodePath = "",
  [string[]]$Packages = @()
)

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }
function Write-Err($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# 1) Validar Node 20
function Get-NodePath {
  param([string]$NodePathOverride)
  if ($NodePathOverride -and (Test-Path $NodePathOverride)) { return $NodePathOverride }
  $cmd = Get-Command node -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Path }
  return ""
}

$nodeExe = Get-NodePath -NodePathOverride $NodePath
if (-not $nodeExe) {
  Write-Err "Node não encontrado no PATH. Instale Node LTS 20 e forneça -NodePath."
  exit 1
}

# Checar versão
$nodeVersion = & $nodeExe -v
if ($LASTEXITCODE -ne 0) { Write-Err "Não foi possível obter versão do Node."; exit 1 }
if ($nodeVersion -notmatch '^v20\.') {
  Write-Warn "Versão do Node detectada: $nodeVersion. Recomenda-se Node LTS 20.x para Trae."
}
Write-Info "Usando Node em: $nodeExe ($nodeVersion)"

# 2) Preparar diretório
Write-Info "Criando diretório isolado: $TargetDir"
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

# 3) Inicializar package.json local para controle (opcional)
if (-not (Test-Path (Join-Path $TargetDir 'package.json'))) {
  Write-Info "Inicializando package.json no diretório alvo"
  npm init -y --prefix $TargetDir | Out-Null
}

# 4) Instalar pacotes MCP (se fornecidos)
if ($Packages.Count -gt 0) {
  Write-Info "Instalando MCPs: $($Packages -join ', ')"
  npm install --prefix $TargetDir @($Packages) | Out-Null
  if ($LASTEXITCODE -ne 0) { Write-Err "Falha ao instalar pacotes MCP."; exit 1 }
} else {
  Write-Warn "Nenhum pacote fornecido em -Packages. Pulando instalação."
}

# 5) Listar caminhos de entrypoint candidatos (dist/index.js)
Write-Info "Verificando entrypoints (dist/index.js) nos pacotes instalados"
$nodeModules = Join-Path $TargetDir 'node_modules'
if (Test-Path $nodeModules) {
  Get-ChildItem -Path $nodeModules -Directory | ForEach-Object {
    $pkg = $_.Name
    $distIndex = Join-Path $_.FullName 'dist\index.js'
    if (Test-Path $distIndex) {
      Write-Host "- pacote: $pkg" -ForegroundColor Green
      Write-Host "  entrypoint: $distIndex"
      Write-Host "  command: $nodeExe"
      Write-Host "  args: $distIndex"
    } else {
      $binDir = Join-Path $_.FullName 'bin'
      if (Test-Path $binDir) {
        Write-Warn "pacote: $pkg — não há dist/index.js; verifique scripts/bin disponíveis em $binDir"
      } else {
        Write-Warn "pacote: $pkg — entrypoint não encontrado; consulte documentação do MCP"
      }
    }
  }
} else {
  Write-Warn "node_modules não encontrado em $TargetDir"
}

Write-Info "Concluído. Configure cada MCP no Trae apontando para $nodeExe e o dist/index.js do pacote."

<#
Exemplos de uso:

1) Apenas preparar diretório e package.json:
   .\scripts\trae-mcp-setup.ps1

2) Preparar e instalar GitHub MCP e Brave MCP com Node 20 específico:
   .\scripts\trae-mcp-setup.ps1 -NodePath "C:\\Program Files\\nodejs\\node.exe" -Packages @(
     "github-mcp-custom",
     "@cyanheads/git-mcp-server",
     "@brave-intl/brave-search-mcp"
   )

3) Diretório customizado por usuário:
   .\scripts\trae-mcp-setup.ps1 -TargetDir "C:\\Users\\Zappro\\.trae\\mcp" -Packages @("github-mcp-custom")

Depois da instalação, no Trae IDE:
- command: C:\\Program Files\\nodejs\\node.exe
- args:    C:\\Users\\Zappro\\.trae\\mcp\\node_modules\\<pacote>\\dist\\index.js
- env:     defina variáveis por MCP diretamente no Trae
#>

