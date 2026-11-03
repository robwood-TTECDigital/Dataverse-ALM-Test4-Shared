@{
    # Local validation and CI import these exact versions to keep findings comparable.
    Tools = @{
        Pester = '5.7.1'
        PSScriptAnalyzer = '1.24.0'
        'powershell-yaml' = '0.4.12'
    }
    AnalyzerSettings = @{
        IncludeDefaultRules = $true
        ExcludeRules = @(
            'PSAvoidUsingWriteHost'
        )
    }
    # Each tuple must match exactly once. Source is executable text, not a line number;
    # do not refresh entries just to hide new findings or stale suppressions.
    Exceptions = @(
        @{
            Path = 'setup-azdo.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Add-EntraIdFederatedCredential'
            Source = '[Parameter(Mandatory)][string]$CredentialName'
            Reason = 'This is the display name of a federated identity credential, not a secret.'
        }
        @{
            Path = 'setup-github.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Add-EntraIdFederatedCredential'
            Source = '[Parameter(Mandatory)][string]$CredentialName'
            Reason = 'This is the display name of a federated identity credential, not a secret.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Get-CredentialSummaryText'
            Source = '[Parameter()]$Credentials'
            Reason = 'This public helper consumes a structured authentication configuration. Changing its object contract requires a separate credential-handling audit.'
        }
        @{
            Path = 'setup-github.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Set-GitHubPrefixedEnvironmentCredential'
            Source = '[Parameter(Mandatory)][object]$Credentials'
            Reason = 'The setup API consumes structured authentication configuration for GitHub credential provisioning; SecureString is not a compatible replacement.'
        }
        @{
            Path = 'setup-github.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Get-GitHubCredentialsForEnvironment'
            Source = '[Parameter()][object]$ExistingCredential'
            Reason = 'This is existing authentication configuration including non-secret identity metadata; changing its object contract requires a separate audit.'
        }
        @{
            Path = 'setup-github.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Get-GitHubEnvironmentConfiguration'
            Source = '[Parameter()][object]$ExistingCredential'
            Reason = 'This is existing authentication configuration including non-secret identity metadata; changing its object contract requires a separate audit.'
        }
        @{
            Path = 'setup-azdo.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Get-PowerPlatformSCCredential'
            Source = '[Parameter()][object]$ExistingCredential'
            Reason = 'This is existing service-connection authentication configuration; changing its object contract requires a separate audit.'
        }
        @{
            Path = 'setup-azdo.ps1'
            Rule = 'PSAvoidUsingPlainTextForPassword'
            Function = 'Get-AzDoEnvironmentConfiguration'
            Source = '[Parameter()][object]$ExistingCredential'
            Reason = 'This is existing service-connection authentication configuration; changing its object contract requires a separate audit.'
        }
        @{
            Path = 'setup-azdo.ps1'
            Rule = 'PSAvoidUsingConvertToSecureStringWithPlainText'
            Function = '<script>'
            Source = 'ConvertTo-SecureString -String $adoAccessToken.Token -AsPlainText -Force'
            Reason = 'The existing OAuth API supplies a plaintext access token; conversion adapts it to the downstream SecureString contract, not a hardcoded secret.'
        }
        @{
            Path = 'pipelines/scripts/connect-az.ps1'
            Rule = 'PSAvoidUsingConvertToSecureStringWithPlainText'
            Function = '<script>'
            Source = 'ConvertTo-SecureString -String $clientSecret -AsPlainText -Force'
            Reason = 'The secret comes from the protected Azure DevOps service connection at runtime and must be converted to SecureString for Connect-AzAccount.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-SpectreTable'
            Source = 'New-SpectreTable'
            Reason = 'Builds a transient console table. Console dependency initialization is a rendering prerequisite, not a user-selected provisioning operation.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-SpectrePanel'
            Source = 'New-SpectrePanel'
            Reason = 'Builds a transient console panel. Console dependency initialization is a rendering prerequisite, not a user-selected provisioning operation.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-SpectreInfoGrid'
            Source = 'New-SpectreInfoGrid'
            Reason = 'Builds a transient console grid. Console dependency initialization is a rendering prerequisite, not a user-selected provisioning operation.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-SpectreMetricColumn'
            Source = 'New-SpectreMetricColumn'
            Reason = 'Builds transient console renderables. Console dependency initialization is a rendering prerequisite, not a user-selected provisioning operation.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'Set-SetupWizardContext'
            Source = 'Set-SetupWizardContext'
            Reason = 'Updates only script-local UI state needed to render the wizard; it does not change repository or service configuration.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'Set-SetupPhaseContext'
            Source = 'Set-SetupPhaseContext'
            Reason = 'Updates only script-local UI state needed to render the wizard; it does not change repository or service configuration.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'Set-SetupPromptDocContext'
            Source = 'Set-SetupPromptDocContext'
            Reason = 'Updates only script-local prompt metadata; it does not change repository or service configuration.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-SetupHeroPanel'
            Source = 'New-SetupHeroPanel'
            Reason = 'Formats console heading text. Console dependency initialization is a rendering prerequisite, not a user-selected provisioning operation.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-SetupTipsPanel'
            Source = 'New-SetupTipsPanel'
            Reason = 'Builds a transient console tips panel. Console dependency initialization is a rendering prerequisite, not a user-selected provisioning operation.'
        }
        @{
            Path = 'setup-common.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'Remove-SetupConsoleCancelHandler'
            Source = 'Remove-SetupConsoleCancelHandler'
            Reason = 'Detaches a process-local event handler during cleanup. Confirmation must not leave the handler attached after a prompt completes.'
        }
        @{
            Path = 'setup-azdo.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-AzDoBranchSetupState'
            Source = 'New-AzDoBranchSetupState'
            Reason = 'Returns an in-memory branch-selection object without changing a repository or service.'
        }
        @{
            Path = 'setup-github.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-GitHubBranchSetupState'
            Source = 'New-GitHubBranchSetupState'
            Reason = 'Returns an in-memory branch-selection object without changing a repository or service.'
        }
        @{
            Path = 'setup-github.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-GitHubEnvironmentWifSubject'
            Source = 'New-GitHubEnvironmentWifSubject'
            Reason = 'Formats and returns an OIDC subject string; it does not provision a federated identity credential.'
        }
        @{
            Path = 'pipelines/scripts/build.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-SolutionCheckSeverityCount'
            Source = 'New-SolutionCheckSeverityCount'
            Reason = 'Returns an in-memory severity counter dictionary; it does not change build artifacts or service configuration.'
        }
        @{
            Path = 'pipelines/scripts/build.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'New-Count'
            Source = 'New-Count'
            Reason = 'Returns an in-memory severity counter dictionary inside the parallel worker; it does not change build artifacts or service configuration.'
        }
        @{
            Path = 'tests/GitHubDeployment.Tests.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'Set-DeploymentDispatchFixture'
            Source = 'Set-DeploymentDispatchFixture'
            Reason = 'Sets isolated test environment values that AfterEach restores. Confirmation would prevent deterministic fixture setup.'
        }
        @{
            Path = 'tests/PipelineDeployment.Tests.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'Set-DataverseRecord'
            Source = 'Set-DataverseRecord'
            Reason = 'An empty local command stub for Pester mocks; it performs no Dataverse request or mutation.'
        }
        @{
            Path = 'tests/PipelineExport.Tests.ps1'
            Rule = 'PSUseShouldProcessForStateChangingFunctions'
            Function = 'Set-DataverseSolution'
            Source = 'Set-DataverseSolution'
            Reason = 'An empty local command stub for Pester mocks; it performs no Dataverse request or mutation.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$ModulePath'
            Reason = 'The fork-owned validation worker receives live worker inputs through Start-ThreadJob ArgumentList; Using scope would serialize the module path contract unnecessarily.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$ValidationPath'
            Reason = 'The fork-owned validation worker receives live worker inputs through Start-ThreadJob ArgumentList; Using scope would bypass the explicit worker contract.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$Client'
            Reason = 'The fork-owned validation worker receives a live Dataverse connection through Start-ThreadJob ArgumentList; Using scope could serialize or disconnect the client.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$SourceContext'
            Reason = 'The fork-owned validation worker receives its immutable validation context through Start-ThreadJob ArgumentList; this explicit contract is required for isolated workers.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$Rule'
            Reason = 'The fork-owned validation worker receives each rule through Start-ThreadJob ArgumentList so the scheduler can control rule ordering and concurrency.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$Budget'
            Reason = 'The fork-owned validation worker receives the shared operation budget through Start-ThreadJob ArgumentList to coordinate Dataverse request limits.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$Cancellation'
            Reason = 'The fork-owned validation worker receives the cancellation token through Start-ThreadJob ArgumentList to preserve cooperative shutdown behavior.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$Events'
            Reason = 'The fork-owned validation worker receives the event sink through Start-ThreadJob ArgumentList so worker diagnostics remain correlated.'
        }
        @{
            Path = 'ttec-digital/common/validation-workers.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Invoke-AlmValidationRules'
            Source = '$LogDirectory'
            Reason = 'The fork-owned validation worker receives its log directory through Start-ThreadJob ArgumentList to keep worker reports isolated.'
        }
        @{
            Path = 'ttec-digital/migrate-azdo-repo.ps1'
            Rule = 'PSAvoidUsingConvertToSecureStringWithPlainText'
            Function = '<script>'
            Source = 'ConvertTo-SecureString -String $PersonalAccessToken -AsPlainText -Force'
            Reason = 'The fork-owned migration bridge adapts a user-supplied Azure DevOps PAT to the existing SecureString API; the plaintext exists only at the legacy API boundary and is not hardcoded.'
        }
        @{
            Path = 'ttec-digital/migrate-azdo-repo.ps1'
            Rule = 'PSAvoidUsingConvertToSecureStringWithPlainText'
            Function = '<script>'
            Source = 'ConvertTo-SecureString -String $adoAuthResult.AccessToken -AsPlainText -Force'
            Reason = 'The fork-owned migration bridge adapts the OAuth access token returned by the legacy Azure DevOps API to the existing SecureString API boundary.'
        }
        @{
            Path = 'ttec-digital/migrate-azdo-repo.ps1'
            Rule = 'PSAvoidUsingConvertToSecureStringWithPlainText'
            Function = '<script>'
            Source = 'ConvertTo-SecureString -String $patPlainText -AsPlainText -Force'
            Reason = 'The fork-owned migration bridge adapts a legacy PAT value to the existing SecureString API boundary; no credential is embedded in source.'
        }
        @{
            Path = 'ttec-digital/migrate-azdo-repo.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Get-AuthToken'
            Source = '$ClientId'
            Reason = 'The fork-owned migration token worker receives authentication values through its existing runspace argument contract; Using scope would change legacy token acquisition behavior.'
        }
        @{
            Path = 'ttec-digital/migrate-azdo-repo.ps1'
            Rule = 'PSUseUsingScopeModifierInNewRunspaces'
            Function = 'Get-AuthToken'
            Source = '$Authority'
            Reason = 'The fork-owned migration token worker receives authentication values through its existing runspace argument contract; Using scope would change legacy token acquisition behavior.'
        }
        @{
            Path = 'ttec-digital/migrate-common.psm1'
            Rule = 'PSProvideCommentHelp'
            Function = 'Build-SolutionsSection'
            Source = 'Build-SolutionsSection'
            Reason = 'Legacy fork migration formatter retained for compatibility with existing migration callers; documenting it is deferred to the dedicated migration-tool audit.'
        }
        @{
            Path = 'ttec-digital/migrate-common.psm1'
            Rule = 'PSProvideCommentHelp'
            Function = 'Build-AssetsSection'
            Source = 'Build-AssetsSection'
            Reason = 'Legacy fork migration formatter retained for compatibility with existing migration callers; documenting it is deferred to the dedicated migration-tool audit.'
        }
        @{
            Path = 'ttec-digital/migrate-common.psm1'
            Rule = 'PSProvideCommentHelp'
            Function = 'Build-HooksSection'
            Source = 'Build-HooksSection'
            Reason = 'Legacy fork migration formatter retained for compatibility with existing migration callers; documenting it is deferred to the dedicated migration-tool audit.'
        }
        @{
            Path = 'ttec-digital/migrate-common.psm1'
            Rule = 'PSProvideCommentHelp'
            Function = 'Build-ScriptDependenciesSection'
            Source = 'Build-ScriptDependenciesSection'
            Reason = 'Legacy fork migration formatter retained for compatibility with existing migration callers; documenting it is deferred to the dedicated migration-tool audit.'
        }
        @{
            Path = 'ttec-digital/migrate-common.psm1'
            Rule = 'PSProvideCommentHelp'
            Function = 'Build-LegacySection'
            Source = 'Build-LegacySection'
            Reason = 'Legacy fork migration formatter retained for compatibility with existing migration callers; documenting it is deferred to the dedicated migration-tool audit.'
        }
        @{
            Path = 'ttec-digital/migrate-common.psm1'
            Rule = 'PSProvideCommentHelp'
            Function = 'ConvertTo-PowerShellLiteral'
            Source = 'ConvertTo-PowerShellLiteral'
            Reason = 'Legacy fork migration formatter retained for compatibility with existing migration callers; documenting it is deferred to the dedicated migration-tool audit.'
        }
        @{
            Path = 'ttec-digital/migrate-azdo-repo.ps1'
            Rule = 'PSUseBOMForUnicodeEncodedFile'
            Function = '<script>'
            Source = ''
            Reason = 'The fork-owned executable migration entry point must begin with an unprefixed shebang so pwsh can execute it directly; adding a BOM would break that legacy command-line contract.'
        }
        @{
            Path = 'ttec-digital/migrate-github-repo.ps1'
            Rule = 'PSUseBOMForUnicodeEncodedFile'
            Function = '<script>'
            Source = ''
            Reason = 'The fork-owned executable migration entry point must begin with an unprefixed shebang so pwsh can execute it directly; adding a BOM would break that legacy command-line contract.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseApprovedVerbs'
            Function = 'Cleanup-TestArtifacts'
            Source = 'Cleanup-TestArtifacts'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseApprovedVerbs'
            Function = 'Setup-TestPublishers'
            Source = 'Setup-TestPublishers'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseApprovedVerbs'
            Function = 'Setup-TestSolutions'
            Source = 'Setup-TestSolutions'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseApprovedVerbs'
            Function = 'Setup-TestTables'
            Source = 'Setup-TestTables'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseApprovedVerbs'
            Function = 'Setup-TestEnvironmentVariables'
            Source = 'Setup-TestEnvironmentVariables'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseApprovedVerbs'
            Function = 'Setup-TestComponents'
            Source = 'Setup-TestComponents'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseSingularNouns'
            Function = 'Cleanup-TestArtifacts'
            Source = 'Cleanup-TestArtifacts'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseSingularNouns'
            Function = 'Setup-TestPublishers'
            Source = 'Setup-TestPublishers'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseSingularNouns'
            Function = 'Setup-TestSolutions'
            Source = 'Setup-TestSolutions'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseSingularNouns'
            Function = 'Setup-TestTables'
            Source = 'Setup-TestTables'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseSingularNouns'
            Function = 'Setup-TestEnvironmentVariables'
            Source = 'Setup-TestEnvironmentVariables'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseSingularNouns'
            Function = 'Setup-TestComponents'
            Source = 'Setup-TestComponents'
            Reason = 'Fork-owned Dataverse validation harness retains its established command names because setup documentation and operator scripts invoke these legacy test lifecycle commands.'
        }
        @{
            Path = 'ttec-digital/tests/solutionvalidation/Invoke-SolutionValidationRuleTests.ps1'
            Rule = 'PSUseBOMForUnicodeEncodedFile'
            Function = '<script>'
            Source = ''
            Reason = 'Fork-owned executable validation harness retains its unprefixed shebang for direct pwsh invocation; adding a BOM would break that command-line contract.'
        }
    )
}