$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$plugin = Get-Content -LiteralPath (Join-Path $root 'plugin.json') -Raw | ConvertFrom-Json
$compat = Get-Content -LiteralPath (Join-Path $root '.codex-plugin\plugin.json') -Raw | ConvertFrom-Json
$null = Get-Content -LiteralPath (Join-Path $root 'opencode.json') -Raw | ConvertFrom-Json
$cases = Get-Content -LiteralPath (Join-Path $root 'tests\activation-cases.md') -Raw
$skills = @(Get-ChildItem -LiteralPath (Join-Path $root 'skills') -Directory)
if ($plugin.'$schema' -ne 'https://agent-plugins.org/schemas/1.0.0/plugin.schema.json') { throw 'Missing portable plugin schema' }
if ($compat.name -ne $plugin.name -or $compat.version -ne $plugin.version) { throw 'Compatibility manifest identity mismatch' }
if ($compat.skills -ne './skills/') { throw 'Compatibility manifest must point to ./skills/' }
$onboarding = $plugin.extensions.'com.openai'.onboardingSkill
if (-not $onboarding -or -not (Test-Path -LiteralPath (Join-Path $root $onboarding))) { throw 'Invalid onboarding skill path' }
if ($skills.Count -ne 4) { throw "Expected 4 skills, got $($skills.Count)" }
foreach ($dir in $skills) {
  $file = Join-Path $dir.FullName 'SKILL.md'
  $text = Get-Content -LiteralPath $file -Raw
  if ($text -notmatch '(?m)^name:\s*([a-z0-9]+(?:-[a-z0-9]+)*)\s*$') { throw "Missing valid name: $($dir.Name)" }
  if ($Matches[1] -ne $dir.Name) { throw "Name mismatch: $($dir.Name)" }
  if ($text -notmatch '(?m)^description:\s*\S.+$') { throw "Missing description: $($dir.Name)" }
  if ($text -notmatch '(?m)^license:\s*MIT\s*$') { throw "Missing MIT metadata: $($dir.Name)" }
  if ($text -match 'TODO|TBD|PLACEHOLDER') { throw "Placeholder found: $($dir.Name)" }
  if ($cases -notmatch [regex]::Escape("## $($dir.Name)")) { throw "Missing activation cases: $($dir.Name)" }
}
$required = @('README.md','LICENSE','THIRD_PARTY.md','templates\AGENTS-routing.md','references\routing-contract.md','references\topologies.md')
foreach ($rel in $required) { if (-not (Test-Path -LiteralPath (Join-Path $root $rel))) { throw "Missing required file: $rel" } }
& (Join-Path $root 'scripts\test-registry.ps1')
Write-Output "PASS: $($skills.Count) skills validated"

