BeforeAll {
    Set-StrictMode -Version Latest
    Import-Module "$PSScriptRoot/../ttec-digital/migrate-common.psm1" -Force
}

Describe 'Legacy configuration migration' {
    It 'generates an importable config without duplicate framework keys' {
        $workspace = Join-Path $TestDrive 'legacy-repository'
        New-Item -ItemType Directory -Path $workspace -Force | Out-Null
        $legacyPath = Join-Path $workspace 'almconfig.ps1'
        @(
            '@{'
            "    Solutions = @('LegacySolution')"
            '    SolutionOptions = @{ LegacySolution = @{ DeployUnmanaged = $true } }'
            "    PostExportScript = 'scripts/post-export.ps1'"
            "    LegacyValue = 'preserved'"
            '}'
        ) | Set-Content -LiteralPath $legacyPath
        $outputPath = Join-Path $workspace 'alm-config.psd1'

        $result = Invoke-ConfigMigration `
            -WorkspacePath $workspace `
            -TemplateDirectory (Join-Path $PSScriptRoot '../copy-to-your-repo') `
            -AlmConfigPath $legacyPath `
            -OutputPath $outputPath

        $result.Migrated | Should -BeTrue
        $config = Import-PowerShellDataFile -Path $outputPath
        $config.solutions[0].name | Should -Be 'LegacySolution'
        $config.solutions[0].deployUnmanaged | Should -BeTrue
        $config.LegacyValue | Should -Be 'preserved'
        $config.hooks.postExport | Should -Contain 'scripts/post-export.ps1'
        $config.ContainsKey('PostExportScript') | Should -BeFalse
        Test-Path (Join-Path $workspace 'almconfig.ps1.migrated') | Should -BeTrue

        $topLevelKeys = @(
            Select-String -Path $outputPath -Pattern '^\s{4}([A-Za-z][A-Za-z0-9_]*)\s*=' |
                ForEach-Object { $_.Matches[0].Groups[1].Value.ToLowerInvariant() }
        )
        $topLevelKeys | Group-Object | Where-Object Count -gt 1 | Should -BeNullOrEmpty
    }

    It 'handles missing optional legacy keys without strict-mode failures' {
        $workspace = Join-Path $TestDrive 'minimal-legacy-repository'
        New-Item -ItemType Directory -Path $workspace -Force | Out-Null
        $legacyPath = Join-Path $workspace 'almconfig.ps1'
        Set-Content -LiteralPath $legacyPath -Value '@{ Solutions = @() }'
        $outputPath = Join-Path $workspace 'alm-config.psd1'

        { Invoke-ConfigMigration `
                -WorkspacePath $workspace `
                -TemplateDirectory (Join-Path $PSScriptRoot '../copy-to-your-repo') `
                -AlmConfigPath $legacyPath `
                -OutputPath $outputPath } | Should -Not -Throw
        { Import-PowerShellDataFile -Path $outputPath } | Should -Not -Throw
    }
}
