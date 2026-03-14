$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$schemaDir = Join-Path $repoRoot 'doc\schemas\v1'
$examplesDir = Join-Path $schemaDir 'examples'
$jqPath = Join-Path $repoRoot 'tools\jq\jq.exe'
$ajvPath = Join-Path $repoRoot 'node_modules\.bin\ajv.cmd'
if (-not (Test-Path $schemaDir)) {
  throw "Schema directory not found: $schemaDir"
}

if (-not (Test-Path $examplesDir)) {
  throw "Examples directory not found: $examplesDir"
}

if (-not (Test-Path $jqPath)) {
  throw "jq not found at $jqPath"
}

if (-not (Test-Path $ajvPath)) {
  throw "ajv-cli not installed. Run: npm install"
}

$schemaFiles = Get-ChildItem -Path $schemaDir -Filter *.schema.json | Sort-Object Name

if ($schemaFiles.Count -eq 0) {
  throw "No schema files found in $schemaDir"
}

foreach ($schemaFile in $schemaFiles) {
  $refFiles = $schemaFiles |
    Where-Object { $_.FullName -ne $schemaFile.FullName } |
    ForEach-Object { $_.FullName }

  Write-Host "Checking JSON syntax:" $schemaFile.Name
  & $jqPath empty $schemaFile.FullName
  if ($LASTEXITCODE -ne 0) {
    throw "Invalid JSON syntax in $($schemaFile.FullName)"
  }

  Write-Host "Compiling schema:" $schemaFile.Name
  $ajvArgs = @('compile', '--spec=draft2020', '--strict=false', '-c', 'ajv-formats', '-s', $schemaFile.FullName)
  foreach ($refFile in $refFiles) {
    $ajvArgs += @('-r', $refFile)
  }

  & $ajvPath @ajvArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Schema compilation failed for $($schemaFile.FullName)"
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

  Write-Host "Validating example:" ([System.IO.Path]::GetFileName($examplePath))
  $validateArgs = @('validate', '--spec=draft2020', '--strict=false', '-c', 'ajv-formats', '-s', $schemaFile.FullName, '-d', $examplePath)
  foreach ($refFile in $refFiles) {
    $validateArgs += @('-r', $refFile)
  }

  & $ajvPath @validateArgs
  if ($LASTEXITCODE -ne 0) {
    throw "Example validation failed for $examplePath"
  }
}

Write-Host "Schema validation completed successfully."
