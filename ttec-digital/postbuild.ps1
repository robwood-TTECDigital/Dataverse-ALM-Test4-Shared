param($context)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

& $PSScriptRoot/common/load-dataverse-sdk.ps1
import-module $PSScriptRoot/common/alm.psm1

$config = $context.Config
$sourceRoot = [System.IO.Path]::GetFullPath([string]$context.SourceDirectory)
$outputRoot = [System.IO.Path]::GetFullPath([string]$context.ArtifactStagingDirectory)

New-Item -ItemType Directory -Path (Join-Path $outputRoot 'dependencies') -Force -Verbose | Out-Null

if ($config.ContainsKey("DependencySolutions")) {
    @($config.DependencySolutions) | ForEach-Object { Copy-Item -Verbose (Join-Path $sourceRoot ([string]$_)) (Join-Path $outputRoot 'dependencies') }
}

if ($config.ContainsKey("PostDependencySolutions")) {
    @($config.PostDependencySolutions) | ForEach-Object { Copy-Item -Verbose (Join-Path $sourceRoot ([string]$_)) (Join-Path $outputRoot 'dependencies') }
}

if (-not (Test-Path (Join-Path $outputRoot 'data'))) {
    New-Item -ItemType Directory -Path (Join-Path $outputRoot 'data') -Verbose | Out-Null
}
if ($config.ContainsKey("DataSets")) {
    if ($config.DataSets -is [hashtable]) {
        $config.DataSets.Keys | foreach-object {
            Compress-Archive -Path (Join-Path $sourceRoot "data/$_/data/*") -DestinationPath (Join-Path $outputRoot "data/$_.zip")
        }
    }
    else {
        @($config.DataSets) | foreach-object {
            Compress-Archive -Path (Join-Path $sourceRoot "data/$_/data/*") -DestinationPath (Join-Path $outputRoot "data/$_.zip")
        }
    }
}

New-Item -ItemType Directory -Path (Join-Path $outputRoot 'portals') -Force -Verbose | Out-Null
if ($config.ContainsKey("Portals")) {
    $config.Portals.Keys | foreach-object {
        Copy-Item -Recurse (Join-Path $sourceRoot "portals/$_") (Join-Path $outputRoot 'portals')
    }
}

if (Test-Path (Join-Path $sourceRoot 'migrations')) {
    Copy-Item (Join-Path $sourceRoot 'migrations') $outputRoot -Recurse -Verbose
}

Push-Location -LiteralPath $sourceRoot
try {
    synapse_build -config $config -outputpath $outputRoot
}
finally {
    Pop-Location
}
