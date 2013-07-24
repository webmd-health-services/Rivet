
$tempDir = $null
$rivetConfigPath = $null
$minConfig = @'
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases'
}
'@

function Setup
{
    $tempDir = New-TempDirectoryTree -Prefix 'Rivet-Test-GetRivetConfig' @'
+ Databases
* rivet
'@
    $rivetConfigPath = Join-Path -Path $tempDir -ChildPath 'rivet'
    $minConfig | Set-RivetConfig
    Assert-NotNull $rivetConfigPath
    . (Join-Path -Path $TestDir -ChildPath ..\Rivet\Get-RivetConfig.ps1 -Resolve)
}

function TearDown
{
    if( (Test-Path -Path function:\Get-RivetConfig) )
    {
        Remove-Item -Path function:\Get-RivetConfig
    }

    if( (Test-Path -Path $tempDir -PathType Container) )
    {
        Remove-Item -Path $tempDir -Recurse
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
    Assert-True ($config.Databases -is 'Object[]')
    Assert-Equal 1 $config.Databases.Count 
    Assert-Equal $dbName $config.Databases[0].Name
    Assert-Equal (Join-Path -Path $tempDir -ChildPath "Databases\$dbName") $config.Databases[0].Root
}

function Test-ShouldValidateDatabasesDirectoryExists
{
    Remove-Item -Path (Join-Path -Path $tempDir -ChildPath 'Databases') -Recurse

    $Error.Clear()
    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Equal 1 $Error.Count
    Assert-Like $Error[0].Exception.Message '*not found*'
}

function Test-ShouldRequireDatabaseScriptsRoot
{
    @'
{
    SqlServerName: 'Blah\\Blah'
}
'@ | Set-RivetConfig

    $Error.Clear()
    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Equal 1 $Error.Count
    Assert-Like $Error[0].Exception.Message '*missing*'
}

function Test-ShouldRequireSqlServerName
{
    @'
{
    DatabasesRoot: 'Databases'
}
'@ | Set-RivetConfig

    $Error.Clear()
    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Equal 1 $Error.Count
    Assert-Like $Error[0].Exception.Message '*missing*'
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

    $Error.Clear()
    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Equal 1 $Error.Count
    Assert-Like $Error[0].Exception.Message '*invalid*'
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

    $Error.Clear()
    $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
    Assert-Null $config
    Assert-Equal 1 $Error.Count
    Assert-Like $Error[0].Exception.Message '*invalid*'
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