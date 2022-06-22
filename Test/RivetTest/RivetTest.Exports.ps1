
# PowerShell doesn't respect the VariablesToExport and AliasesToExport module manifest properties, so we need to export them here.
$module = Test-ModuleManifest -Path (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest.psd1' -Resolve)
[String[]]$variablesToExport = $module.ExportedVariables.Keys 
[String[]]$aliasesToExport = $module.ExportedAliases.Keys
[String[]]$functionsToExport = $module.ExportedFunctions.Keys
Export-ModuleMember -Variable $variablesToExport -Alias $aliasesToExport -Function $functionsToExport
