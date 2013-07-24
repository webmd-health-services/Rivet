
$tempDir = $null
$rivetConfigPath = $null

function Setup
{
    $tempDir = New-TempDirectoryTree -Prefix 'Rivet-Test-GetRivetConfig' @'
+ Databases
* rivet
'@
    $rivetConfigPath = Join-Path -Path $tempDir -ChildPath 'rivet'
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
    ('One') | 
        ForEach-Object { Join-Path -Path $tempDir -ChildPath "Databases\$_" } |
        ForEach-Object { New-Item -Path $_ -ItemType Container -Force } |
        Out-Null

    @'
{
    SqlServerName: 'computername\\instancename',
    DatabasesRoot: 'Databases'
}
'@ | Set-RivetConfig

    $config = Get-RivetConfig -Path $rivetConfigPath

    Assert-NotNull $config
    Assert-Equal 'computername\instancename' $config.SqlServerName
    Assert-Equal 15 $config.ConnectionTimeout   # Default
    Assert-Equal 30 $config.CommandTimeout      # Default
    Assert-True ($config.Databases -is 'Object[]')
    Assert-Equal 1 $config.Databases.Count 
    Assert-Equal 'One' $config.Databases[0].Name
    Assert-Equal (Join-Path -Path $tempDir -ChildPath 'Databases\One') $config.Databases[0].ScriptsRoot
}

function Test-ShouldValidateDatabasesDirectoryExists
{
    Remove-Item -Path (Join-Path -Path $tempDir -ChildPath 'Databases') -Recurse
    @'
{
    SqlServerName: 'Hello\\World',
    DatabasesRoot: 'Databases'
}
'@ | Set-RivetConfig 

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

filter Set-RivetConfig
{
    param(
        $FileName
    )

    if( $FileName )
    {
        $rivetConfigPath = Join-Path -Path $tempDir -ChildPath $FileName
    }
    else
    {
        $rivetConfigPath = Join-Path -Path $tempDir -ChildPath 'rivet'
    }
    $_ | Set-Content -Path $rivetConfigPath
}