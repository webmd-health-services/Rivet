
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

    $testDirectory = Join-Path -Path ([IO.Path]::GetTempPath()) -ChildPath ([IO.Path]::GetRandomFileName())
    if ($TestDrive | Get-Member -Name 'FullName')
    {
        $testDirectory = $TestDrive.FullName
    }
    else
    {
        $testDirectory = $TestDrive
    }

    if (-not (Test-Path -Path $testDirectory))
    {
        New-Item -Path $testDirectory -ItemType 'Directory' | Out-Null
    }

    Get-ChildItem -Path $testDirectory | Remove-Item -Recurse -Force -ErrorAction Continue

    $script:RTTestRoot = Join-Path -Path $testDirectory -ChildPath ([IO.Path]::GetRandomFileName())
    if (-not (Test-Path -Path $script:RTTestRoot))
    {
        New-Item -Path $script:RTTestRoot -ItemType 'Directory' | Out-Null
    }

    $script:RTDatabasesRoot = Join-Path -Path $script:RTTestRoot -ChildPath 'Databases'
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

    $script:RTSession = New-RivetSession -ConfigurationPath $script:RTConfigFilePath
    Connect-RivetSession -Session $script:RTSession

    Write-RTTiming ('Start-RivetTest  END')
}
