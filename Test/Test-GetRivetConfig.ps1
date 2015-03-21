
$tempDir = $null
$rivetConfigPath = $null
$minConfig = @'
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    PluginsRoot: 'Plugins'
}
'@

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Import-Rivet.ps1' -Resolve)

function Start-Test
{
    $tempDir = New-TempDirectoryTree -Prefix 'Rivet-Test-GetRivetConfig' @'
+ Databases
+ Plugins
* rivet
'@
    $rivetConfigPath = Join-Path -Path $tempDir -ChildPath 'rivet'
    $minConfig | Set-RivetConfig
    Assert-NotNull $rivetConfigPath
}

function Stop-Test
{
    if( $tempDir -and (Test-Path -Path $tempDir -PathType Container) )
    {
        Remove-Item -Path $tempDir -Recurse
    }
}

function Test-ShouldHandleRelativePath
{
    $tempDirName = Split-Path -Leaf -Path $tempDir
    $tempDir2 = New-TempDir -Prefix 'Rivet-Test-GetRivetConfig'
    $tempDir2Name = Split-Path -Leaf -Path $tempDir2
    $configContents = @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: '..\\$tempDirName\\Databases'
}
"@
    $configContents | Set-Content -Path (Join-Path -Path $tempDir2 -ChildPath 'rivet.json')

    Push-Location -Path $tempDir
    try
    {
        $config = Get-RivetConfig -Path ('..\{0}\rivet.json' -f $tempDir2Name)
        Assert-NotNull $config
        Assert-Equal (Join-Path -Path $tempDir -ChildPath 'Databases') $config.DatabasesRoot
    }
    finally
    {
        Pop-Location
        Remove-Item -Path $tempDir2 -Recurse
    }
}

function Test-ShouldParseMinimumConfig
{
    $dbName = [Guid]::NewGuid().ToString()
    $dbName | New-DatabaseDirectory

    $config = Get-RivetConfig -Path $rivetConfigPath

    Assert-NotNull $config
    Assert-Equal '.\Test' $config.SqlServerName
    Assert-Equal 15 $config.ConnectionTimeout   # Default
    Assert-Equal 30 $config.CommandTimeout      # Default
    Assert-True ($config.Databases -is 'Collections.Generic.List[Rivet.Configuration.Database]')
    Assert-Equal 1 $config.Databases.Count 
    Assert-Equal $dbName $config.Databases[0].Name
    Assert-Equal 0 $config.Databases[0].TargetDatabaseNames.Count
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\$dbName") $config.Databases[0].Root
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\$dbName\Migrations") $config.Databases[0].MigrationsRoot
    Assert-True ($config.PluginsRoot -is 'Collections.Generic.List[string]')
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Plugins") $config.PluginsRoot[0]
}

function Test-ShouldValidateDatabasesDirectoryExists
{
    Remove-Item -Path (Join-Path -Path $tempDir -ChildPath 'Databases') -Recurse

    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Error -Last 'not found'
}

function Test-ShouldValidatePluginDirectoryExists
{
    Remove-Item -Path (Join-Path -Path $tempDir -ChildPath 'Plugins') -Recurse

    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Error -Last 'not found'
}

function Test-ShouldRequireDatabaseScriptsRoot
{
    @'
{
    SqlServerName: 'Blah\\Blah'
}
'@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Error -Last 'missing'
}

function Test-ShouldRequireSqlServerName
{
    @'
{
    DatabasesRoot: 'Databases'
}
'@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Error -Last 'missing'
}

function Test-ShouldParseSqlServerName
{
    $sqlServerName = [Guid]::NewGuid().ToString()
    @"
{
    SqlServerName: '$sqlServerName',
    DatabasesRoot: 'Databases'
}
"@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath
    Assert-NotNull $config
    Assert-Equal $sqlServerName $config.SqlServerName
}

function Test-ShouldParseConnectionTimeout
{
    @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    ConnectionTimeout: 300
}
"@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath
    Assert-NotNull $config
    Assert-Equal 300 $config.ConnectionTimeout
}

function Test-ShouldValidateConnectionTimeout
{
    @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    ConnectionTimeout: 'blah'
}
"@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Error -Last 'invalid'
}

function Test-ShouldParseCommandTimeout
{
    @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    CommandTimeout: 300
}
"@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath
    Assert-NotNull $config
    Assert-Equal 300 $config.CommandTimeout
}

function Test-ShouldValidateCommandTimeout
{
    @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    CommandTimeout: 'blah'
}
"@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Error -Last 'invalid'
}

function Test-ShouldParseRivetConfigInCurrentDirectory
{
    @'
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases'
}
'@ | Set-RivetConfig -FileName 'rivet.json'

    Push-Location -Path $tempDir
    try
    {
        $config = Get-RivetConfig
        Assert-NotNull $config
        Assert-Equal "$tempDir\Databases" $config.DatabasesRoot
    }
    finally
    {
        Pop-Location
    }
}

function Test-ShouldFindAllDatabases
{
    $dbNames = @('One','Three','Two') 
    $dbNames | New-DatabaseDirectory

    $config = Get-RivetConfig -Path $rivetConfigPath
    Assert-NotNull $config
    Assert-Equal 3 $config.Databases.Count
    
    $idx = 0
    $dbNames | ForEach-Object {
        Assert-Equal $_ $config.Databases[$idx].Name 
        Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\$_") $config.Databases[$idx].Root
        $idx += 1
    }
}

function Test-ShouldIgnoreDatabases
{
    $dbNames = @( 'One', 'Two', 'Three' )
    $dbNames | New-DatabaseDirectory

    @'
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    IgnoreDatabases: [ 'Tw*', 'Thr*' ]
}
'@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath
    Assert-NotNull $config
    Assert-Equal 1 $config.Databases.Count
    Assert-Equal 'One' $config.Databases[0].Name
}

function Test-ShouldHandleOneIgnoreRule
{
    'One' | New-DatabaseDirectory

    @'
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    IgnoreDatabases: 'One'
}
'@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath
    Assert-NotNull $config
    Assert-Equal 0 $config.Databases.Count
}

function Test-ShouldOverrideSettingsFromEnvironment
{
    $uatDatabasesPath = Join-Path $tempDir 'UatDatabases'
    $null = New-Item -Path $uatDatabasesPath -ItemType 'Directory'
    $null = New-Item -Path (Join-Path $uatDatabasesPath 'Shared') -ItemType 'Directory'
    $null = New-Item -Path (Join-Path $uatDatabasesPath 'UatDatabase') -ItemType 'Directory'
    @'
{
    SqlServerName: '.\\Rivet',
    DatabasesRoot: 'Databases',
    Environments: {
        UAT: {
            SqlServerName: 'uatdb\\Rivet',
            ConnectionTimeout: 999,
            IgnoreDatabases: [ 'Shared' ],
            DatabasesRoot: 'UatDatabases'
        },
        Prod: {
            SqlServerName: 'proddb\\Rivet'
        }
    }
}
'@ | Set-RivetConfig

    $databasesRootPath = Join-Path $tempDir 'Databases'
    $defaultConfig = Get-RivetConfig -Path $rivetConfigPath
    $uatConfig = Get-RivetConfig -Path $rivetConfigPath -Environment 'UAT'
    $prodConfig = Get-RivetConfig -Path $rivetConfigPath -Environment 'Prod'
    Assert-Equal '.\Rivet' $defaultConfig.SqlServerName
    Assert-Equal $databasesRootPath $defaultConfig.DatabasesRoot
    Assert-Equal 15 $defaultConfig.ConnectionTimeout
    Assert-Equal 0 $defaultConfig.Databases.Count

    Assert-Equal 'uatdb\Rivet' $uatConfig.SqlServerName
    Assert-Equal $uatDatabasesPath $uatConfig.DatabasesRoot
    Assert-Equal 999 $uatConfig.ConnectionTimeout
    Assert-Equal 1 $uatConfig.Databases.Count
    Assert-Equal 'UatDatabase' $uatConfig.Databases[0].Name

    Assert-Equal 'proddb\Rivet' $prodConfig.SqlServerName
    Assert-Equal $databasesRootPath $prodConfig.DatabasesRoot
    Assert-Equal 15 $prodConfig.ConnectionTimeout
    Assert-Equal 0 $prodConfig.Databases.Count
}

function Test-ShouldReturnExplicitDatabases
{
    $config = Get-RivetConfig -Path $rivetConfigPath -Database 'one','two'
    Assert-NotNull $config
    Assert-Equal 2 $config.Databases.Count
    Assert-Equal 'one' $config.Databases[0].Name
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\one") $config.Databases[0].Root
    Assert-Equal 'two' $config.Databases[1].Name
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\two") $config.Databases[1].Root
}

function Test-ShouldReturnUniqueDatabases
{
    $db = [Guid]::NewGuid().ToString()
    $db | New-DatabaseDirectory

    $config = Get-RivetConfig -Path $rivetConfigPath -Database $db
    Assert-NotNull $config
    Assert-Equal 1 $config.Databases.Count
    Assert-Equal $db $config.Databases[0].Name
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\$db") $config.Databases[0].Root
}

function Test-ShouldOnlyReturnExplicitDatabases
{
    $db = [Guid]::NewGuid().ToString()
    $db | New-DatabaseDirectory

    $config = Get-RivetConfig -Path $rivetConfigPath -Database 'one'
    Assert-NotNull $config
    Assert-Equal 1 $config.Databases.Count
    Assert-Equal 'one' $config.Databases[0].Name
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\one") $config.Databases[0].Root
}

function Test-ShouldFailIfEnvironmentMissing
{
    $dbName = [Guid]::NewGuid().ToString()
    $dbName | New-DatabaseDirectory

    $config = Get-RivetConfig -Path $rivetConfigPath -Environment 'IDoNotExist' -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Error -Last 'Environment ''IDoNotExist'' not found'
}


function Test-ShouldParseTargetDatabases
{
    $uatDatabasesPath = Join-Path $tempDir 'UatDatabases'
    $null = New-Item -Path $uatDatabasesPath -ItemType 'Directory'
    $null = New-Item -Path (Join-Path $uatDatabasesPath 'Shared') -ItemType 'Directory'
    $null = New-Item -Path (Join-Path $uatDatabasesPath 'UatDatabase') -ItemType 'Directory'
    @'
{
    SqlServerName: '.\\Rivet',
    DatabasesRoot: 'UatDatabases',
    TargetDatabases: {
                        'UatDatabase': [ 'DB2', 'DB3' ]
                     }
}
'@ | Set-RivetConfig

    $defaultConfig = Get-RivetConfig -Path $rivetConfigPath
    [Rivet.Configuration.Database]$db1 = $defaultConfig.Databases | Where-Object { $_.Name -eq 'UatDatabase' }
    Assert-True ($db1.TargetDatabaseNames -contains 'DB2')
    Assert-True ($db1.TargetDatabaseNames -contains 'DB3')

    [Rivet.Configuration.Database]$db2 = $defaultConfig.Databases | Where-Object { $_.Name -eq 'Shared' }
    Assert-Equal 0 $db2.TargetDatabaseNames.Count

}

function Set-RivetConfig
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        # The config to set.
        $InputObject,

        [string]
        # The filename to use.
        $FileName
    )

    begin
    {
        if( $FileName )
        {
            $rivetConfigPath = Join-Path -Path $tempDir -ChildPath $FileName
        }
    }
    process
    {
        $InputObject | Set-Content -Path $rivetConfigPath
    }
}

filter New-DatabaseDirectory
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string]
        $Name
    )

    $Name |
        ForEach-Object { Join-Path -Path $tempDir -ChildPath "Databases\$_" } |
        ForEach-Object { New-Item -Path $_ -ItemType Container -Force } |
        Out-Null

}