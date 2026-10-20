# TTEC Hook Configuration

This page catalogs the additional `alm-config.psd1` options read by the TTEC
data, deployment, export, validation, and Azure Synapse hooks. These settings
are optional and have inert defaults. For shared pipeline settings, merge rules,
and standard hook contracts, see the [ALM configuration reference](../../docs/config/alm-config.md).

The copied configuration template exposes these settings. Empty arrays, maps,
and strings leave the corresponding behavior inactive. Values are merged with
the framework defaults: maps merge recursively, arrays append, and scalar
application values override defaults.

## Export and Validation

| Setting | Shape | Behavior |
| --- | --- | --- |
| `ExternalDependencySolutionNames` | Array of solution unique-name strings | Adds external solutions to the solution-validation dependency checks. |
| `IgnoreSolutions` | Array of solution unique-name strings | Excludes these solutions from solution-validation dependency checks. |
| `validation.parallel` | Boolean; default `$true` | Runs validation rules concurrently; `$false` runs them sequentially. |
| `validation.maxParallel` | Integer from `1` to `8`; default `4` | Maximum concurrent rules for one solution. Rules share the `export.maxConcurrentOperations` budget with package exports. |
| `solutions[].validationMode` | `error`, `warning`, or `disabled`; default `error` | Controls how validation findings affect the export. |
| `solutions[].skipValidationRules` | Array of maps with required `ruleName` (string) and `mode` (`skip`, `warning`, or `error`); optional `componentType` (integer), `componentId` (GUID), and `componentSchemaName` (string) | Applies rule-wide or component-scoped overrides. See [component-specific validation configuration](./solution-validation.md#component-specific-configuration). |

```powershell
ExternalDependencySolutionNames = @('ContosoShared')
IgnoreSolutions = @('ContosoLegacy')
validation = @{
    parallel = $true
    maxParallel = 4
}
solutions = @(
    @{
        name = 'ContosoCore'
        validationMode = 'warning'
        skipValidationRules = @(
            @{ ruleName = 'SolutionUsesSystemPublisher'; mode = 'skip' }
            @{ ruleName = 'ComponentIsUnmanagedNonCustom'; mode = 'warning' }
        )
    }
)
```

See [Solution Validation](./solution-validation.md) for rule details, component
overrides, validation modes, and report output.

## Deployment

| Setting | Shape | Behavior |
| --- | --- | --- |
| `DependencySolutions` | Array of artifact-relative solution package paths | Imports these packages before data, team, and portal operations. |
| `PostDependencySolutions` | Array of artifact-relative solution package paths | Imports these packages after data, team, and portal operations. |
| `AadGroupTeams` | Array of maps: optional `BusinessUnitName` (string); required `TeamId` and `AadGroupId` (GUIDs), `TeamName` (string), `RoleNames` (string array) | Ensures Azure AD group teams exist and synchronizes their security roles. `AadGroupId` supports `$(Name)` placeholders supplied through `CONFIG_Name` variables. |
| `BuDefaultTeams` | Array of maps: optional `BusinessUnitName` (string); `RoleNames` (string array) | Synchronizes roles on the business unit's default team. An empty business unit name selects the root business unit. |
| `OwnerTeams` | Array of maps: optional `BusinessUnitName` (string); required `TeamId` (GUID), `TeamName` (string), `RoleNames` (string array) | Ensures owner teams exist and synchronizes their roles. |
| `AccessTeams` | Array of maps: optional `BusinessUnitName` (string); required `TeamId` (GUID), `TeamName` (string) | Ensures access teams exist. |
| `ApplicationUsers` | Array of maps: `ApplicationId` (GUID), optional `BusinessUnitName` (string), `RoleNames` (string array) | Ensures Dataverse application users exist and synchronizes their roles. `ApplicationId` supports `$(Name)` placeholders. |
| `PluginSteps` | Array of maps: `PluginStepId` (GUID), `SecureConfig` (string) | Sets plug-in step secure configuration. `SecureConfig` supports `$(Name)` placeholders. |
| `CanvasAppSharing` | Array of maps: `UniqueName` (string), `AadGroupIds` (GUID array) | Shares each canvas app with the configured Entra ID groups; the configured group list replaces prior group sharing. |
| `FlowSharing` | Array of maps: `WorkflowId` (GUID), `AadGroupIds` (GUID array) | Shares each cloud flow with the configured Entra ID groups; the configured group list replaces prior group sharing. |

```powershell
DependencySolutions = @('solutions/ContosoShared_managed.zip')
PostDependencySolutions = @('solutions/ContosoReporting_managed.zip')
AadGroupTeams = @(
    @{
        BusinessUnitName = ''
        TeamId = '00000000-0000-0000-0000-000000000001'
        TeamName = 'Managers'
        AadGroupId = '$(ManagersGroupId)'
        RoleNames = @('Basic User')
    }
)
BuDefaultTeams = @(
    @{ BusinessUnitName = ''; RoleNames = @('Basic User') }
)
OwnerTeams = @(
    @{
        BusinessUnitName = ''
        TeamId = '00000000-0000-0000-0000-000000000002'
        TeamName = 'Case Owners'
        RoleNames = @('Basic User')
    }
)
AccessTeams = @(
    @{
        BusinessUnitName = ''
        TeamId = '00000000-0000-0000-0000-000000000003'
        TeamName = 'Case Readers'
    }
)
ApplicationUsers = @(
    @{
        ApplicationId = '$(IntegrationAppId)'
        BusinessUnitName = ''
        RoleNames = @('Basic User')
    }
)
PluginSteps = @(
    @{
        PluginStepId = '00000000-0000-0000-0000-000000000004'
        SecureConfig = '$(PluginSecret)'
    }
)
CanvasAppSharing = @(
    @{ UniqueName = 'contoso_customerportal'; AadGroupIds = @('$(ReadersGroupId)') }
)
FlowSharing = @(
    @{ WorkflowId = '00000000-0000-0000-0000-000000000005'; AadGroupIds = @('$(ReadersGroupId)') }
)
```

The GUIDs above are illustrative only and must be replaced with the target
environment's IDs. `CONFIG_<name>` values provide `$(<name>)` substitutions
for team, application-user, and plug-in configuration.

The configured team and application-user role lists synchronize the target's
assignments to the listed roles. Canvas app and flow sharing remove group
assignments not present in the configured list. Keep environment-specific
identifiers and secrets in pipeline variables rather than in the PSD1 file.

## Azure Synapse

| Setting | Shape | Behavior |
| --- | --- | --- |
| `SynapseFolders` | Array of Synapse folder names | Enables asset export, packaging, and deployment for the listed folders. Requires `SynapseRepositoryUrl`. |
| `SynapseRepositoryUrl` | String | Git clone URL for the Synapse development repository. Azure DevOps uses `SYSTEM_ACCESSTOKEN` when available. |
| `SynapseLinkedServicesInclude` | Array of wildcard patterns | Includes matching linked services. |
| `SynapseLinkedServicesExclude` | Array of wildcard patterns | Excludes matching linked services; `*WorkspaceDefault*` is excluded by default. |
| `SynapseManagedPrivateEndpoints` | Array of maps: `Name` (string), `Definition` (JSON string) | Creates or updates Synapse managed private endpoints. Both values support `$(Name)` deployment placeholders. |

See [Azure Synapse integration](./azure-synapse.md) for configuration examples,
environment variables, and asset behavior.

## Legacy Settings

These settings remain supported for existing repositories, but should not be used
for new configuration. Their defaults are retained for compatibility.

| Setting | Legacy shape and behavior | Use instead |
| --- | --- | --- |
| `DataSets` | Array of dataset-name strings, or a map from dataset name to a settings map. Map entries may set `Stage = 'BeforeTeams'`; other entries deploy afterward. The old flow exports and deploys files under `data/<name>`. | Use the standard data hooks and assets workflow described in [Data import and export](../../docs/config/example-hooks/data-import-export.md). |
| `DefaultEnvVarValues` | Map from environment-variable schema name to a default value. `DATAVERSEENVVAR_<schema-name>` variables override configured defaults. | Set target-specific values in pipeline variables using the `DATAVERSEENVVAR_<schema-name>` name instead of storing values in the repository configuration. |
| `OrgSettings` | Map from organization-table attribute logical name to value; applied by the legacy `preDeploy` hook. | Use the shared [`organizationSettings` or `orgDbOrgSettings` configuration](../../docs/config/alm-config.md#organization-settings). |
| `Portals` | Map from portal unique name to website ID. `PORTALCONFIG_<name>` variables provide portal deployment-profile substitutions. | Include Power Pages components in configured solutions and use the solution-aware pipeline. See [Solutions](../../docs/config/alm-config.md#solutions) and [Adding Dataverse components](../../docs/usage/adding-dataverse-components.md#solutions). |
