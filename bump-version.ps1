Param(
  [string]$IndexPath = (Join-Path $PSScriptRoot "index.html")
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $IndexPath)) {
  throw "index.html not found: $IndexPath"
}

$content = Get-Content -LiteralPath $IndexPath -Raw -Encoding UTF8

$m = [regex]::Match($content, "const\s+VERSION\s*=\s*'(\d+)\.(\d+)\.(\d+)'\s*;")
if (-not $m.Success) {
  throw "Could not find VERSION in index.html. Expected: const VERSION = 'x.y.z';"
}

$major = [int]$m.Groups[1].Value
$minor = [int]$m.Groups[2].Value
$patch = [int]$m.Groups[3].Value
$newVersion = "$major.$minor.$($patch + 1)"

$newContent = [regex]::Replace(
  $content,
  "const\s+VERSION\s*=\s*'\d+\.\d+\.\d+'\s*;",
  "const VERSION = '$newVersion';",
  1
)

Set-Content -LiteralPath $IndexPath -Value $newContent -Encoding UTF8

Write-Host "Bumped VERSION: $($m.Groups[0].Value) -> const VERSION = '$newVersion';"
