function Set-AlmManagementPartner {
    <#
    .SYNOPSIS
        Creates or updates the configured Azure management partner association.
    .DESCRIPTION
        Requires an existing Az PowerShell login context. Creates the association
        when none exists, updates it when the partner ID differs, and leaves a
        matching association unchanged. Only a 404 response or the management
        partner service's explicit no-link response is treated as an absent
        association; other errors stop the preDeploy hook. Supports -WhatIf and
        -Confirm before changing the association.
    .PARAMETER PartnerId
        Numeric Microsoft partner ID configured by ALM.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$PartnerId
    )

    $PartnerId = $PartnerId.Trim()
    if ($PartnerId -notmatch '^\d+$') {
        throw "partnerId '$PartnerId' must contain only digits."
    }

    $azContext = Get-AzContext -ErrorAction Stop
    if ($null -eq $azContext) {
        throw 'An Az PowerShell login context is required to manage partnerId. Sign in to Azure before deployment.'
    }

    $existingPartner = $null
    try {
        $existingPartner = Get-AzManagementPartner -ErrorAction Stop
    }
    catch {
        $exception = $_.Exception
        $partnerNotFound = $false
        while ($null -ne $exception) {
            if ($exception.Message -match 'This user or service principal is not linked with a Partner ID') {
                $partnerNotFound = $true
                break
            }

            $responseProperty = $exception.PSObject.Properties['Response']
            if ($null -ne $responseProperty -and $null -ne $responseProperty.Value) {
                $statusCodeProperty = $responseProperty.Value.PSObject.Properties['StatusCode']
                if ($null -ne $statusCodeProperty -and [int]$statusCodeProperty.Value -eq 404) {
                    $partnerNotFound = $true
                    break
                }
            }
            $exception = $exception.InnerException
        }

        if (-not $partnerNotFound) {
            throw
        }
    }

    if ($null -eq $existingPartner) {
        if ($PSCmdlet.ShouldProcess($PartnerId, 'Create Azure management partner link')) {
            Write-Host "##[section]Creating Azure management partner link: $PartnerId"
            New-AzManagementPartner -PartnerId $PartnerId -ErrorAction Stop | Out-Null
        }
    }
    elseif ([string]$existingPartner.PartnerId -ne $PartnerId) {
        if ($PSCmdlet.ShouldProcess($PartnerId, 'Update Azure management partner link')) {
            Write-Host "##[section]Updating Azure management partner link from $($existingPartner.PartnerId) to $PartnerId"
            Update-AzManagementPartner -PartnerId $PartnerId -ErrorAction Stop | Out-Null
        }
    }
    else {
        Write-Host "##[debug]Azure management partner link already matches partnerId $PartnerId"
    }
}
