BeforeAll {
    $repoRoot = Split-Path $PSScriptRoot -Parent
    . (Join-Path $repoRoot 'ttec-digital/common/management-partner.ps1')

    function Get-ExistingManagementPartnerForTest {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Pester mock scope shares this test fixture state through a global value.')]
        param()
        $global:existingManagementPartner
    }

    function Set-ExistingManagementPartnerForTest {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = 'Pester mock scope shares this test fixture state through a global value.')]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Test-only fixture state setter.')]
        param($Partner)
        $global:existingManagementPartner = $Partner
    }

    function Get-AzContext {}
    function Get-AzManagementPartner {}
    function New-AzManagementPartner {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pester stub for an Az cmdlet.')]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Mock command signature; Pester inspects these arguments.')]
        param($PartnerId)
    }
    function Update-AzManagementPartner {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pester stub for an Az cmdlet.')]
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Justification = 'Mock command signature; Pester inspects these arguments.')]
        param($PartnerId)
    }
}

Describe 'PreDeploy management partner hook' {
    BeforeEach {
        Mock Get-AzContext { [pscustomobject]@{ Account = 'deployment-identity' } }
        Mock Get-AzManagementPartner { Get-ExistingManagementPartnerForTest }
        Mock New-AzManagementPartner {}
        Mock Update-AzManagementPartner {}
        Set-ExistingManagementPartnerForTest -Partner $null
    }

    It 'creates a link when the current association does not exist' {
        Set-AlmManagementPartner -PartnerId '6479631'

        Should -Invoke New-AzManagementPartner -Times 1 -Exactly -ParameterFilter { $PartnerId -eq '6479631' }
        Should -Invoke Update-AzManagementPartner -Times 0 -Exactly
    }

    It 'creates a link when Azure reports that no partner association exists' {
        Mock Get-AzManagementPartner {
            throw "Operation failed with message 'This user or service principal is not linked with a Partner ID'"
        }

        Set-AlmManagementPartner -PartnerId '6479631'

        Should -Invoke New-AzManagementPartner -Times 1 -Exactly -ParameterFilter { $PartnerId -eq '6479631' }
        Should -Invoke Update-AzManagementPartner -Times 0 -Exactly
    }

    It 'propagates unrelated partner lookup errors' {
        Mock Get-AzManagementPartner { throw 'Partner lookup service unavailable.' }

        { Set-AlmManagementPartner -PartnerId '6479631' } | Should -Throw '*Partner lookup service unavailable*'

        Should -Invoke New-AzManagementPartner -Times 0 -Exactly
    }

    It 'does not change the association when WhatIf is requested' {
        Set-AlmManagementPartner -PartnerId '6479631' -WhatIf

        Should -Invoke New-AzManagementPartner -Times 0 -Exactly
        Should -Invoke Update-AzManagementPartner -Times 0 -Exactly
    }

    It 'updates a link when the configured partner ID differs' {
        Set-ExistingManagementPartnerForTest -Partner ([pscustomobject]@{ PartnerId = '1234567' })
        Set-AlmManagementPartner -PartnerId '6479631'

        Should -Invoke Update-AzManagementPartner -Times 1 -Exactly -ParameterFilter { $PartnerId -eq '6479631' }
        Should -Invoke New-AzManagementPartner -Times 0 -Exactly
    }

    It 'leaves a matching link unchanged' {
        Set-ExistingManagementPartnerForTest -Partner ([pscustomobject]@{ PartnerId = '6479631' })
        Set-AlmManagementPartner -PartnerId '6479631'

        Should -Invoke New-AzManagementPartner -Times 0 -Exactly
        Should -Invoke Update-AzManagementPartner -Times 0 -Exactly
    }

    It 'fails when the Azure login context has not been established' {
        Mock Get-AzContext { $null }

        { Set-AlmManagementPartner -PartnerId '6479631' } | Should -Throw '*Az PowerShell login context is required*'

        Should -Invoke Get-AzManagementPartner -Times 0 -Exactly
    }

    It 'rejects a non-numeric partner ID' {
        { Set-AlmManagementPartner -PartnerId 'not-a-number' } | Should -Throw '*must contain only digits*'

        Should -Invoke Get-AzContext -Times 0 -Exactly
    }

    It 'uses the configured partner ID from the preDeploy hook' {
        $hookPath = Join-Path $repoRoot 'ttec-digital/predeploy-management-partner.ps1'
        $context = @{ Config = @{ partnerId = 6479631 } }

        & $hookPath -context $context

        Should -Invoke New-AzManagementPartner -Times 1 -Exactly -ParameterFilter { $PartnerId -eq '6479631' }
    }

    It 'skips partner management when partnerId is blank' {
        $hookPath = Join-Path $repoRoot 'ttec-digital/predeploy-management-partner.ps1'
        $context = @{ Config = @{ partnerId = '' } }

        & $hookPath -context $context

        Should -Invoke Get-AzContext -Times 0 -Exactly
        Should -Invoke New-AzManagementPartner -Times 0 -Exactly
        Should -Invoke Update-AzManagementPartner -Times 0 -Exactly
    }
}
