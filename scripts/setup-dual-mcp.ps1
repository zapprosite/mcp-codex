<#
  setup-dual-mcp.ps1 - Windows 11
  Executar em PowerShell (User ou Admin conforme necessário)
  Dicas:
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
#>

Write-Host "🔧 Setup Dual MCP - Windows 11" -ForegroundColor Cyan

# Limpar duplicatas no PATH (Machine)
try {
  $env:PATH = ($env:PATH.Split(';') | Select-Object -Unique) -join ';'
  [Environment]::SetEnvironmentVariable("PATH", $env:PATH, "Machine")
  Write-Host "✅ PATH limpo" -ForegroundColor Green
} catch {
  Write-Host "⚠️  Não foi possível atualizar PATH a nível de máquina. Prosseguindo..." -ForegroundColor Yellow
}

# Verificar Node.js no WSL
Write-Host "🔎 Verificando Node.js no WSL" -ForegroundColor Cyan
wsl -e node --version
wsl -e npm --version
Write-Host "✅ Node.js WSL verificado" -ForegroundColor Green

