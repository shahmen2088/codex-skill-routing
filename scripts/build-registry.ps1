param(
  [Parameter(Mandatory=$true)][string[]]$Roots,
  [Parameter(Mandatory=$true)][string]$OutputPath
)
$ErrorActionPreference = 'Stop'
$entries = @()
foreach ($rootInput in $Roots) {
  $root = [System.IO.Path]::GetFullPath($rootInput)
  if (-not (Test-Path -LiteralPath $root -PathType Container)) { throw "Skill root not found: $root" }
  Get-ChildItem -LiteralPath $root -Filter 'SKILL.md' -File -Recurse | ForEach-Object {
    $text = Get-Content -LiteralPath $_.FullName -Raw
    $frontmatter = [regex]::Match($text, '\A---\s*\r?\n(?<yaml>.*?)\r?\n---', 'Singleline')
    if (-not $frontmatter.Success) { return }
    $yaml = $frontmatter.Groups['yaml'].Value
    $nameMatch = [regex]::Match($yaml, '(?m)^name:\s*["'']?(?<value>[^"''\r\n]+)')
    $descriptionMatch = [regex]::Match($yaml, '(?m)^description:\s*["'']?(?<value>[^"''\r\n]+)')
    if (-not $nameMatch.Success -or -not $descriptionMatch.Success) { return }
    $entries += [pscustomobject]@{
      name = $nameMatch.Groups['value'].Value.Trim()
      description = $descriptionMatch.Groups['value'].Value.Trim()
      path = $_.FullName
      sourceRoot = $root
    }
  }
}
$duplicates = $entries | Group-Object name | Where-Object Count -gt 1
if ($duplicates) { throw "Duplicate skill names: $(($duplicates.Name | Sort-Object) -join ', ')" }
$ordered = @($entries | Sort-Object name, path)
$parent = Split-Path -Parent ([System.IO.Path]::GetFullPath($OutputPath))
if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
$ordered | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $OutputPath -Encoding utf8
Write-Output "PASS: wrote $($ordered.Count) skills to $OutputPath"

