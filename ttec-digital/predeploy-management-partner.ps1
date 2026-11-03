<#
.SYNOPSIS
    Creates or updates the Azure management partner association before solution deployment.
.DESCRIPTION
    Runs as a preDeploy hook and reads partnerId from the hook configuration.
    A blank partnerId disables the operation. Requires an authenticated Az
    PowerShell context and permission to manage the identity's partner association.
    Azure errors are allowed to stop deployment.
.PARAMETER context
    ALM hook context containing the deployment configuration.
#>
param($context)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3.0

$config = $context.Config
$partnerId = if ($null -eq $config.partnerId) { '' } else { ([string]$config.partnerId).Trim() }
if (-not [string]::IsNullOrWhiteSpace($partnerId)) {
    . (Join-Path $PSScriptRoot 'common/management-partner.ps1')
    Set-AlmManagementPartner -PartnerId $partnerId
}
