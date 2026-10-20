$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-skill-routing-" + [guid]::NewGuid().ToString('N'))
try {
  $alpha = Join-Path $temp 'alpha'
  $beta = Join-Path $temp 'beta'
  New-Item -ItemType Directory -Force -Path $alpha, $beta | Out-Null
  "---`nname: alpha`ndescription: First fixture`n---`n# Alpha" | Set-Content -LiteralPath (Join-Path $alpha 'SKILL.md') -Encoding utf8
  "---`nname: beta`ndescription: Second fixture`n---`n# Beta" | Set-Content -LiteralPath (Join-Path $beta 'SKILL.md') -Encoding utf8
  $output = Join-Path $temp 'registry.json'
  & (Join-Path $root 'scripts\build-registry.ps1') -Roots $temp -OutputPath $output | Out-Null
  $registry = @(Get-Content -LiteralPath $output -Raw | ConvertFrom-Json)
  if ($registry.Count -ne 2) { throw "Expected 2 entries, got $($registry.Count)" }
  if ($registry[0].name -ne 'alpha' -or $registry[1].name -ne 'beta') { throw 'Registry order is not deterministic' }
  if ($registry[0].PSObject.Properties.Name -contains 'body') { throw 'Registry must not include skill bodies' }
  Write-Output 'PASS: registry builder'
}
finally {
  if ([System.IO.Directory]::Exists($temp)) { [System.IO.Directory]::Delete($temp, $true) }
}

