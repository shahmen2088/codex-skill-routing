param([ValidateSet('codex','opencode')][string]$Target='codex')
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$base = if ($Target -eq 'codex') { Join-Path $env:USERPROFILE '.codex\skills' } else { Join-Path $env:USERPROFILE '.config\opencode\skills' }
New-Item -ItemType Directory -Force -Path $base | Out-Null
$skills = @(Get-ChildItem (Join-Path $repo 'skills') -Directory)
$existing = @($skills | ForEach-Object { Join-Path $base $_.Name } | Where-Object { Test-Path -LiteralPath $_ })
if ($existing.Count -gt 0) { throw "Installation stopped; target already exists: $($existing -join ', ')" }
$skills | ForEach-Object {
  $dest = Join-Path $base $_.Name
  Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse
  Write-Output "Installed $($_.Name) to $dest"
}

