
function Start-RivetTest
{
    [CmdletBinding()]
    param(
        # Optional Parameter to specify a plugin Path
        [String[]] $PluginPath,

        [String[]] $IgnoredDatabase,

        [Alias('DatabaseName')]
        [String[]] $PhysicalDatabase = $RTDatabaseName,

        [String[]] $ConfigurationDatabase,

        [int] $CommandTimeout = 30
    )
    
    Set-StrictMode -Version Latest

    Write-RTTiming ('Start-RivetTest  BEGIN')

    $Global:Error.Clear()

    if( (Test-Pester) )
    {
        $testDirectory = $TestDrive
        if( $testDirectory | Get-Member -Name 'FullName' )
        {
            $testDirectory = $testDirectory.FullName
        }
        
        $script:RTTestRoot = Join-Path -Path $testDirectory -ChildPath ([IO.Path]::GetRandomFileName())
        New-Item -Path $RTTestRoot -ItemType 'Directory' | Out-Null
    }
    else
    {
        $script:RTTestRoot = New-TempDir -Prefix 'RivetTest'
    }

    $script:RTDatabasesRoot = Join-Path -Path $RTTestRoot -ChildPath 'Databases'
    foreach( $name in $PhysicalDatabase )
    {
        $script:RTDatabaseRoot = Join-Path $RTDatabasesRoot $name
        $script:RTDatabaseMigrationRoot = Join-Path -Path $RTDatabaseRoot -ChildPath 'Migrations'
        $null = New-Item -Path $RTDatabaseMigrationRoot -ItemType Container -Force
    }
    
    $script:RTConfigFilePath = Join-Path -Path $RTTestRoot -ChildPath 'rivet.json'

    Push-Location -Path $RTTestRoot
    try
    {
        foreach( $item in $PluginPath )
        {
            if( -not (Test-Path -Path $item -PathType Container) )
            {
                New-Item -Path $item -ItemType 'Directory'
            }
        }
    }
    finally
    {
        Pop-Location
    }

    $PluginPathClause = ''
    if ($PluginPath)
    {
        $PluginPathClause = ",""PluginPaths"": {0}" -f (ConvertTo-Json -InputObject $PluginPath)
    }

    $IgnoreClause = ''
    if( $IgnoredDatabase )
    {
        $IgnoreClause = ',IgnoreDatabases: [ "{0}" ]' -f ($IgnoredDatabase -join '", "')
    }

    $content = @"
{
    SqlServerName: '$($RTServer.Replace('\', '\\'))',
    DatabasesRoot: '$($RTDatabasesRoot.Replace('\','\\'))',
    CommandTimeout: $($CommandTimeout)
"@

    if( $ConfigurationDatabase )
    {
        $content += @"
,
    Databases: [ "$($ConfigurationDatabase -join """, """)" ]
"@
    }

    $content += @"
    $PluginPathClause
    $IgnoreClause
}
"@
    $content | Set-Content -Path $RTConfigFilePath

    Write-RTTiming ('Start-RivetTest  END')
}
