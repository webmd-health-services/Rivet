
function Start-RivetTest
{
    [CmdletBinding()]
    param(
        [string]
        # Optional Parameter to specify a plugin Path
        $PluginPath,

        [string[]]
        $IgnoredDatabase
    )
    
    Set-StrictMode -Version Latest
    
    $tempDir = New-TempDir -Prefix 'RivetTest'

    $script:RTDatabasesRoot = Join-Path -Path $tempDir -ChildPath 'Databases'
    $script:RTDatabaseRoot = Join-Path $RTDatabasesRoot $RTDatabaseName
    $script:RTDatabaseMigrationRoot = Join-Path -Path $RTDatabaseRoot -ChildPath 'Migrations'

    $null = New-Item -Path $RTDatabaseMigrationRoot -ItemType Container -Force
    
    $script:RTConfigFilePath = Join-Path -Path $tempDir -ChildPath 'rivet.json'

    $PluginPathClause = ''
    if ($PluginPath)
    {
        $PluginPathClause = ",PluginsRoot: '{0}'" -f $PluginPath
        $PluginPathClause = $PluginPathClause.Replace('\','\\')
    }

    $IgnoreClause = ''
    if( $IgnoredDatabase )
    {
        $IgnoreClause = ',IgnoreDatabases: [ "{0}" ]' -f ($IgnoredDatabase -join '", "')
    }

    @"
{
    SqlServerName: '$($RTServer.Replace('\', '\\'))',
    DatabasesRoot: '$($RTDatabasesRoot.Replace('\','\\'))'
    $PluginPathClause
    $IgnoreClause
}
"@ | Set-Content -Path $RTConfigFilePath
}
