$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$venvPath = Join-Path $repoRoot ".venv-gesture"
$pythonPath = Join-Path $venvPath "Scripts\python.exe"

if (-not (Test-Path -LiteralPath $pythonPath)) {
    python3.12 -m venv $venvPath
}

& $pythonPath -m pip install -r (Join-Path $PSScriptRoot "gesture-requirements.txt")
Write-Host "Gesture camera environment is ready. Use Start Camera inside the game."
