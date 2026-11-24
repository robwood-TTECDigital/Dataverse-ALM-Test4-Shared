$rnwoodModule = Get-Module -Name Rnwood.Dataverse.Data.PowerShell | Select-Object -First 1
if (-not $rnwoodModule) {
  Import-Module -Name Rnwood.Dataverse.Data.PowerShell -Global -ErrorAction Stop
  $rnwoodModule = Get-Module -Name Rnwood.Dataverse.Data.PowerShell | Select-Object -First 1
}

$sdkAssemblyNames = @('Microsoft.Xrm.Sdk', 'Microsoft.Crm.Sdk.Proxy')
$loadedSdkAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies() |
  Where-Object { $sdkAssemblyNames -contains $_.GetName().Name }
$xrmSdkAssembly = @($loadedSdkAssemblies).Where({ $_.GetName().Name -eq 'Microsoft.Xrm.Sdk' }, 'First')
if (-not $xrmSdkAssembly) {
  throw 'Microsoft.Xrm.Sdk.dll was not loaded by Rnwood.Dataverse.Data.PowerShell.'
}
$typeAccelerators = [System.Management.Automation.PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators', $true)
$typeAcceleratorAdd = $typeAccelerators.GetMethod(
  'Add',
  [System.Reflection.BindingFlags]'Public,NonPublic,Static')
$typeAcceleratorMap = $typeAccelerators.GetProperty('Get').GetValue($null)
$registeredTypeCount = 0
foreach ($sdkAssemblyName in $sdkAssemblyNames) {
  $sdkAssembly = @($loadedSdkAssemblies).Where({ $_.GetName().Name -eq $sdkAssemblyName }, 'First')
  if (-not $sdkAssembly) {
    $sdkAssemblyPath = Get-ChildItem -LiteralPath $rnwoodModule.ModuleBase -Recurse -Filter "$sdkAssemblyName.dll" -File |
      Where-Object { $_.FullName -match '[\\/]loader[\\/]net' } |
      Select-Object -First 1
    if (-not $sdkAssemblyPath) {
      throw "$sdkAssemblyName was not loaded by Rnwood.Dataverse.Data.PowerShell and was not found under '$($rnwoodModule.ModuleBase)'."
    }
    $sdkAssembly = [System.Runtime.Loader.AssemblyLoadContext]::GetLoadContext($xrmSdkAssembly).LoadFromAssemblyPath($sdkAssemblyPath.FullName)
  }

  foreach ($sdkType in $sdkAssembly.GetExportedTypes()) {
    if (-not $typeAcceleratorMap.ContainsKey($sdkType.FullName)) {
      $typeAcceleratorAdd.Invoke($null, [object[]] @($sdkType.FullName, $sdkType)) | Out-Null
      $registeredTypeCount++
    }
  }
}
