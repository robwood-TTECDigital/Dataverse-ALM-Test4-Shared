param($context)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 3.0

$config = $context.Config
$sourceRoot = [System.IO.Path]::GetFullPath([string]$context.SourceDirectory)
$tempRoot = [System.IO.Path]::GetFullPath([string]$context.TempDirectory)

& $PSScriptRoot/common/load-dataverse-sdk.ps1
Import-Module $PSScriptRoot/common/alm.psm1

Push-Location -LiteralPath $sourceRoot
try {

if (-not (Test-Path (Join-Path $sourceRoot 'data')) ) {
    New-Item (Join-Path $sourceRoot 'data') -ItemType Directory | Out-Null
}

# DATA

function exportDataset($datasetname) {
    write-host "Exporting data set '$datasetname'"
    $tempdatafile = Join-Path $tempRoot "data-$datasetname.zip"
    pac data export --schemafile (Resolve-Path (Join-Path $sourceRoot "data/$datasetname/schema.xml")) --overwrite --datafile $tempdatafile
    if (-not $? -or $LASTEXITCODE -ne 0) { throw "pac data export failed"; }
    if (Test-Path (Join-Path $sourceRoot "data/$datasetname/data")) {
        Remove-Item -Recurse -Force (Join-Path $sourceRoot "data/$datasetname/data")
    }
    New-Item -ItemType Directory (Join-Path $sourceRoot "data/$datasetname/data") | Out-Null
    Expand-Archive -Path $tempdatafile -DestinationPath (Join-Path $sourceRoot "data/$datasetname/data")
}

if ($config.ContainsKey("DataSets")) {
    if ($config.DataSets -is [hashtable]) {
        $config.DataSets.Keys | foreach-object {
            exportDataset -datasetname $_

        }
    }
    else {
        foreach ($datasetname in $config.DataSets) {
            exportDataset -datasetname $datasetname
        }
    }
}

git -C $sourceRoot add -A data/
if (-not $? -or $LASTEXITCODE -ne 0) { throw "git add failed"; }

# PORTALS

if (-not (Test-Path (Join-Path $sourceRoot 'portals')) ) {
    New-Item (Join-Path $sourceRoot 'portals') -ItemType Directory | Out-Null
}

if ($config.ContainsKey("Portals")) {
    if (-not (Test-Path (Join-Path $sourceRoot 'portals/cfg')) ) {
        New-Item (Join-Path $sourceRoot 'portals/cfg') -ItemType Directory | Out-Null
    }

    foreach ($portalname in $config.Portals.Keys) {

        $tempfolder = Join-Path $tempRoot "portal-$portalname"
        New-Item -ItemType Directory $tempfolder | Out-Null

        pac paportal download --overwrite --path "$tempfolder" --webSiteId ($config.Portals[$portalname])
        if (-not $? -or $LASTEXITCODE -ne 0) { throw "pac paportal export failed"; }

        $portalcfgpath = Join-Path $sourceRoot "portals/$portalname/cfg"
        if (test-path $portalcfgpath ) {
            remove-item -force -recurse $portalcfgpath
        }

        New-Item -ItemType Directory $portalcfgpath | Out-Null

        copy-item -recurse $tempfolder/*/* $portalcfgpath -exclude .portalconfig

        $profiletemplatepath = Join-Path $sourceRoot "portals/$portalname/deployment-profile-template.yml"
        if (-not (test-path $profiletemplatepath)) {
            (
                "# See https://learn.microsoft.com/en-us/power-pages/configure/power-platform-cli#use-deployment-profile",
                "# Put `$(Placeholders) in where an environment specific value should be used."
            ) | out-file $profiletemplatepath
        }
    }
}

git -C $sourceRoot add -A portals/
if (-not $? -or $LASTEXITCODE -ne 0) { throw "git add failed"; }

synapse_export -config $config


$validdependencysolutionnames = @()
if ($config.ContainsKey("ExternalDependencySolutionNames")) {
    $validdependencysolutionnames += @($config['ExternalDependencySolutionNames'] | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
}
if ($config.ContainsKey("DependencySolutions")) {
    $validdependencysolutionnames += @($config['DependencySolutions'] | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
}
$ignoresolutionnames = @()
if ($config.ContainsKey("IgnoreSolutions")) {
    $ignoresolutionnames = @($config['IgnoreSolutions'] | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
}
$validationSettings = Get-AlmValidationSettings -Config $config

foreach ($solutionconfig in $config.solutions) {

    $laterSolutionNames = @()
    $foundCurrentSolution = $false
    foreach ($configuredSolution in $config.solutions) {
        if ($foundCurrentSolution) {
            $laterSolutionNames += $configuredSolution.name
        } elseif ($configuredSolution.name -eq $solutionconfig.name) {
            $foundCurrentSolution = $true
        }
    }

    Write-Host "[$($solutionconfig.name)][Validate] Reporting validation"

    $validationParameters = @{ ValidationSettings = $validationSettings }
    if ($context.ContainsKey('ExportOperationBudget') -and $context['ExportOperationBudget'] -is [System.Threading.SemaphoreSlim]) {
        $validationParameters.OperationBudget = $context['ExportOperationBudget']
    }
    if ($context.ContainsKey('ExportCancellationToken') -and $context['ExportCancellationToken'] -is [System.Threading.CancellationToken]) {
        $validationParameters.CancellationToken = $context['ExportCancellationToken']
    }
    if ($context.ContainsKey('ExportValidationSummaries') -and $context['ExportValidationSummaries'] -is [hashtable]) {
        $validationParameters.SummaryStore = $context['ExportValidationSummaries']
    }
    if ($context.ContainsKey('ArtifactStagingDirectory') -and $context['ArtifactStagingDirectory']) {
        $validationParameters.LogDirectory = Join-Path $context['ArtifactStagingDirectory'] "export-logs/$($solutionconfig.name)"
    }
    $precomputedResults = $null
    if ($context.ContainsKey('ParallelExportSolutionHookResults') -and $context['ParallelExportSolutionHookResults'] -is [hashtable] -and $context['ParallelExportSolutionHookResults'].ContainsKey($solutionconfig.name) -and $null -ne $context['ParallelExportSolutionHookResults'][$solutionconfig.name]) {
        $precomputedResults = $context['ParallelExportSolutionHookResults'][$solutionconfig.name]
    } elseif ($context.ContainsKey('SolutionHookResults') -and $context['SolutionHookResults'] -is [hashtable] -and $context['SolutionHookResults'].ContainsKey($solutionconfig.name) -and $null -ne $context['SolutionHookResults'][$solutionconfig.name]) {
        $precomputedResults = $context['SolutionHookResults'][$solutionconfig.name]
    } elseif ($context.ContainsKey('ExportValidationResults') -and $context['ExportValidationResults'] -is [hashtable] -and $context['ExportValidationResults'].ContainsKey($solutionconfig.name) -and $null -ne $context['ExportValidationResults'][$solutionconfig.name]) {
        $precomputedResults = $context['ExportValidationResults'][$solutionconfig.name]
    }
    if ($null -ne $precomputedResults) {
        $validationParameters.PrecomputedResults = @($precomputedResults)
    }
    validateSolution `
        -solutionname $solutionconfig.name `
        -validdependencysolutionnames $validdependencysolutionnames `
        -ignoresolutionnames $ignoresolutionnames `
        -solutionconfig $solutionconfig @validationParameters `
        -LaterSolutionNames $laterSolutionNames

    $validdependencysolutionnames += $solutionconfig.name
}

}
finally {
    Pop-Location
}
