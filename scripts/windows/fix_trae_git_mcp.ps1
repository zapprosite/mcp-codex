<#
  Fix Trae IDE Git MCP on Windows
  - Ensures Node LTS (20.x) is available at Program Files
  - Installs @cyanheads/git-mcp-server under %USERPROFILE%\.trae\mcp\git
  - Prints the Trae MCP config block to paste in Settings

  Usage (run as regular user in PowerShell):
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    ./scripts/windows/fix_trae_git_mcp.ps1
#>

param(
  [string]$GitHubToken = "$env:GITHUB_TOKEN",
  [string]$UserHome = "$env:USERPROFILE",
  [string]$NodeLtsPath = "C:\\Program Files\\nodejs\\node.exe",
  [string]$NodeX86Path = "C:\\Program Files (x86)\\nodejs\\node.exe"
)

function Get-NodeVersion($path) {
  if (Test-Path $path) { try { & $path -v } catch { "error" } } else { "not found" }
}

Write-Host "== Node versions ==" -ForegroundColor Cyan
$vDefault = (Get-Command node -ErrorAction SilentlyContinue) ? (& node -v) : "node: not found"
$vLts = Get-NodeVersion $NodeLtsPath
$vX86 = Get-NodeVersion $NodeX86Path
Write-Host ("default: {0}" -f $vDefault)
Write-Host ("LTS    : {0}" -f $vLts)
Write-Host ("x86    : {0}" -f $vX86)

if ($vLts -eq "not found") {
  Write-Warning "Node LTS not found at Program Files. Attempting install via winget (or chocolatey fallback)."
  try {
    winget install -e --id OpenJS.NodeJS.LTS -h --accept-source-agreements --accept-package-agreements
  } catch {
    Write-Warning "winget failed or not available. Trying chocolatey..."
    try { choco install nodejs-lts -y } catch { Write-Warning "choco install failed. Please install Node LTS manually." }
  }
}

# Ensure directory structure
$GitMcpRoot = Join-Path $UserHome ".trae\mcp\git"
New-Item -ItemType Directory -Force -Path $GitMcpRoot | Out-Null
Set-Location $GitMcpRoot

Write-Host "== Clearing NPX cache (optional) ==" -ForegroundColor Cyan
$npxCache = Join-Path $env:LOCALAPPDATA "npm-cache\_npx"
if (Test-Path $npxCache) { Remove-Item -Recurse -Force $npxCache -ErrorAction SilentlyContinue }

Write-Host "== Installing Git MCP ==" -ForegroundColor Cyan
try {
  if (-not (Test-Path (Join-Path $GitMcpRoot "package.json"))) {
    npm init -y | Out-Null
  }
  npm install @cyanheads/git-mcp-server --omit=dev --silent
} catch {
  Write-Error "Failed to install @cyanheads/git-mcp-server. Please check npm configuration."
}

$dist = Join-Path $GitMcpRoot "node_modules\@cyanheads\git-mcp-server\dist\index.js"
if (-not (Test-Path $dist)) {
  Write-Error "dist/index.js not found at $dist"
  exit 1
}

Write-Host "\n== Trae MCP config block ==" -ForegroundColor Green
$cmd = $NodeLtsPath
$arg = $dist
$token = if ([string]::IsNullOrWhiteSpace($GitHubToken)) { "ghp_YOUR_TOKEN_HERE" } else { $GitHubToken }

$config = @{
  name = "Git"
  type = "stdio"
  command = $cmd
  args = @($arg)
  env = @{ GITHUB_TOKEN = $token }
} | ConvertTo-Json -Depth 4

Write-Output $config

Write-Host "\nNext steps:" -ForegroundColor Yellow
Write-Host "1) Open Trae IDE → Settings → MCPs"
Write-Host "2) Disable/Remove existing 'GitHub' MCP that uses npx"
Write-Host "3) Add New MCP and paste the JSON shown above"
Write-Host "4) Save and restart Trae IDE"
Write-Host "5) Test: git_status tool in Trae"

exit 0

