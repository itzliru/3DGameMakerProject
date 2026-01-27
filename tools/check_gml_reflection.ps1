<# PowerShell wrapper for gml_reflection_lint.py — falls back to a conservative Select-String scan if Python isn't available #>
param(
    [string]$Root = "..\"
)

$py = Get-Command python -ErrorAction SilentlyContinue
if ($py) {
    & python (Join-Path $PSScriptRoot 'gml_reflection_lint.py') $Root; exit $LASTEXITCODE
}

# Fallback: quick heuristic checks
$errors = @()
$patterns = @(
    'function_exists\(\s*[A-Za-z_]','function_exists\(\s*"', 'script_exists\(\s*"[A-Za-z_]+'
)
foreach ($p in $patterns) {
    $matches = Select-String -Path "**\*.gml" -Pattern $p -SimpleMatch -ErrorAction SilentlyContinue
    if ($matches) { $errors += $matches }
}
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Host $_ }
    exit 1
}
Write-Host "No obvious reflection issues found (heuristic)."; exit 0
