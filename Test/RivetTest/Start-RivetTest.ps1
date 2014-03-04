
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

    $script:RTDatabasesRoot = Join-Path $tempDir (Split-Path -Leaf $RTDatabasesSourcePath)
    $script:RTDatabaseName = '{0}{1}' -f $RTDatabaseSourceName,(get-date).ToString('yyyyMMddHHmmss')
    $script:RTDatabaseRoot = Join-Path $RTDatabasesRoot $RTDatabaseName
    $script:RTDatabaseMigrationRoot = Join-Path -Path $RTDatabaseRoot -ChildPath 'Migrations'

    if( (Test-Path -Path (Join-Path -Path $RTDatabasesSourcePath -ChildPath $RTDatabaseSourceName) -PathType Container) )
    {
        Copy-Item -Path $RTDatabasesSourcePath -Destination $tempDir -Recurse
        Rename-Item -Path (Join-Path $RTDatabasesRoot $RTDatabaseSourceName) -NewName $RTDatabaseName
    }
    else
    {
        $null = New-Item -Path $RTDatabaseMigrationRoot -ItemType Container -Force
    }
    
    Remove-RivetTestDatabase

    New-Database

    $script:RTDatabaseConnection = New-SqlConnection 

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
