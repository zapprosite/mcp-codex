#!/usr/bin/env pwsh
# Carrega variáveis do arquivo .env apenas para o processo atual e executa o comando informado.
# Uso:
#   .\scripts\codex-env.ps1 codex mcp list
#   .\scripts\codex-env.ps1 python scripts/test-mcps.py
# Se nenhum comando for passado, apenas carrega o .env e abre um shell interativo.

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $ArgsToRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Determina o caminho do projeto (um nível acima de scripts/)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$EnvPath = Join-Path $ProjectRoot '.env'

if (-not (Test-Path $EnvPath)) {
    Write-Error "Arquivo .env não encontrado em $EnvPath. Copie .env.example para .env e preencha as variáveis."
}

# Carrega .env (ignora linhas em branco e comentários)
$lines = Get-Content -Path $EnvPath -Encoding UTF8
foreach ($line in $lines) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
    if ($trimmed.StartsWith('#')) { continue }

    # Divide na primeira ocorrência de '='
    $idx = $trimmed.IndexOf('=')
    if ($idx -lt 1) { continue }

    $key = $trimmed.Substring(0, $idx).Trim()
    $val = $trimmed.Substring($idx + 1).Trim()

    # Remove aspas envolventes, se houver
    if (($val.StartsWith('"') -and $val.EndsWith('"')) -or ($val.StartsWith("'") -and $val.EndsWith("'"))) {
        $val = $val.Substring(1, $val.Length - 2)
    }

    # Exporta para o ambiente do processo atual
    Set-Item -Path Env:$key -Value $val
}

Write-Host "[OK] .env carregado no ambiente do processo atual." -ForegroundColor Green

if ($ArgsToRun -and $ArgsToRun.Count -gt 0) {
    Write-Host "[RUN] Executando comando: $($ArgsToRun -join ' ')"
    $command = $ArgsToRun[0]
    $remaining = @()
    if ($ArgsToRun.Count -gt 1) {
        $remaining = $ArgsToRun[1..($ArgsToRun.Count - 1)]
    }
    & $command @remaining
    exit $LASTEXITCODE
} else {
    Write-Host "[INFO] Nenhum comando informado. Um shell interativo será aberto com .env carregado."
    if ($PSVersionTable.PSEdition -eq 'Core') {
        pwsh
    } else {
        powershell
    }
}
