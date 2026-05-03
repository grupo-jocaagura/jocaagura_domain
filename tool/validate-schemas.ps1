$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$schemaDir = Join-Path $repoRoot 'doc\schemas\v1'
$examplesDir = Join-Path $schemaDir 'examples'
$jqPath = Join-Path $repoRoot 'tool\jq\jq.exe'
$ajvScriptPath = Join-Path $repoRoot 'tool\validate-schemas.mjs'
if (-not (Test-Path $schemaDir)) {
  throw "Schema directory not found: $schemaDir"
}

if (-not (Test-Path $examplesDir)) {
  throw "Examples directory not found: $examplesDir"
}

if (-not (Test-Path $jqPath)) {
  throw "jq not found at $jqPath"
}

if (-not (Test-Path $ajvScriptPath)) {
  throw "AJV validation script not found: $ajvScriptPath"
}

$schemaFiles = Get-ChildItem -Path $schemaDir -Filter *.schema.json | Sort-Object Name

if ($schemaFiles.Count -eq 0) {
  throw "No schema files found in $schemaDir"
}

foreach ($schemaFile in $schemaFiles) {
  Write-Host "Checking JSON syntax:" $schemaFile.Name
  & $jqPath empty $schemaFile.FullName
  if ($LASTEXITCODE -ne 0) {
    throw "Invalid JSON syntax in $($schemaFile.FullName)"
  }

  $exampleBaseName = [System.IO.Path]::GetFileNameWithoutExtension(
    [System.IO.Path]::GetFileNameWithoutExtension($schemaFile.Name)
  )
  $examplePath = Join-Path $examplesDir ($exampleBaseName + '.example.json')

  if (-not (Test-Path $examplePath)) {
    throw "Example file not found for schema $($schemaFile.Name): $examplePath"
  }

  Write-Host "Checking JSON syntax:" ([System.IO.Path]::GetFileName($examplePath))
  & $jqPath empty $examplePath
  if ($LASTEXITCODE -ne 0) {
    throw "Invalid JSON syntax in $examplePath"
  }
}

Write-Host "Running AJV validation script"
node $ajvScriptPath
if ($LASTEXITCODE -ne 0) {
  throw "AJV validation script failed"
}

Write-Host "Schema validation completed successfully."
