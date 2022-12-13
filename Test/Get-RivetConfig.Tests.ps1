
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

$tempDir = $null
$rivetConfigPath = $null
$databasesRootPath = $null
$minConfig = @'
{
    "SqlServerName": ".\\Test",
    "DatabasesRoot": "Databases",
    "PluginPaths": "Plugins"
}
'@

& (Join-Path -Path $PSScriptRoot -ChildPath '..\Rivet\Import-Rivet.ps1' -Resolve)

function GivenConfig
{
    param(
        [string]
        $Config
    )

    $Config | Set-Content -Path $rivetConfigPath
}

function GivenDatabase
{
    param(
        [string[]]
        $Name
    )

    foreach( $dbName in $Name )
    {
        New-Item -Path (Join-Path -Path $databasesRootPath -ChildPath $dbName) -ItemType 'Directory'
    }
}

function GivenDirectory
{
    param(
        $Name
    )

     New-Item -Path (Join-Path -Path ($rivetConfigPath | Split-Path -Parent) -ChildPath $Name) -ItemType 'Directory' -Force
}

function Init
{
    $Global:Error.Clear()
    $script:tempDir = Join-Path -Path $TestDrive.FullName -ChildPath ([IO.Path]::GetRandomFileName())
    $script:databasesRootPath = Join-Path -Path $tempDir -ChildPath 'Databases'
    New-Item -Path $databasesRootPath -ItemType 'Directory' -Force
    New-Item -Path (Join-Path -Path $tempDir -ChildPath 'Plugins') -ItemType 'Directory'
    $script:rivetConfigPath = Join-Path -Path $tempDir -ChildPath 'rivet'
    New-Item -Path $rivetConfigPath -ItemType 'File'
    $minConfig | Set-RivetConfig
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

function WhenGettingConfig
{
    [CmdletBinding()]
    param(
    )
    
    Get-RivetConfig -Path $rivetConfigPath
}

Describe 'Get-RivetConfig' {
    BeforeEach { Init }
    
    It 'should handle relative path' {
        $otherDir = Join-Path -Path $TestDrive.FullName -ChildPath ([IO.Path]::GetRandomFileName())
        New-Item -Path (Join-Path -Path $otherDir -ChildPath 'Databases') -ItemType 'Directory' -Force
        $otherDirName = Split-Path -Path $otherDir -Leaf

        $configContents = @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: '..\\$($otherDirName)\\Databases'
}
"@
        $configContents | Set-Content -Path (Join-Path -Path $otherDir -ChildPath 'rivet.json')
    
        Push-Location -Path $otherDir
        try
        {
            $config = Get-RivetConfig -Path '.\rivet.json'
            $config | Should -Not -BeNullOrEmpty
            $config.DatabasesRoot | Should -Be (Join-Path -Path $otherDir -ChildPath 'Databases')
        }
        finally
        {
            Pop-Location
        }
    }
    
    It 'should parse minimum config' {
        $dbName = [Guid]::NewGuid().ToString()
        $dbName | New-DatabaseDirectory
    
        $config = Get-RivetConfig -Path $rivetConfigPath
    
        $config | Should -Not -BeNullOrEmpty
        $config.SqlServerName | Should -Be '.\Test'
        $config.ConnectionTimeout | Should -Be 15
        $config.CommandTimeout | Should -Be 30
        ($config.Databases -is 'Collections.Generic.List[Rivet.Configuration.Database]') | Should -BeTrue
        $config.Databases.Count | Should -Be 1
        $config.Databases[0].Name | Should -Be $dbName
        $config.Databases[0].Root | Should -Be (Join-Path -Path $tempDir -ChildPath "Databases\$dbName")
        $config.Databases[0].MigrationsRoot | Should -Be (Join-Path -Path $tempDir -ChildPath "Databases\$dbName\Migrations")
        ,$config.PluginPaths | Should -BeOfType ([string[]])
        $config.PluginPaths[0] | Should -Be (Join-Path -Path $tempDir -ChildPath "Plugins")
        ,$config.PluginModules | Should  -BeOfType ([string[]])
        $config.PluginModules | Should -HaveCount 0
    }
    
    It 'should validate databases directory exists' {
        Remove-Item -Path (Join-Path -Path $tempDir -ChildPath 'Databases') -Recurse
    
        $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'not found'
    }
    
    It 'should validate plugin directory exists' {
        Remove-Item -Path (Join-Path -Path $tempDir -ChildPath 'Plugins') -Recurse
    
        $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'does\ not\ exist'
    }
    
    It 'should require database scripts root' {
        @'
{
    SqlServerName: 'Blah\\Blah'
}
'@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'required'
    }
    
    It 'should require sql server name' {
        @'
{
    DatabasesRoot: 'Databases'
}
'@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'required'
    }
    
    It 'should parse sql server name' {
        $sqlServerName = [Guid]::NewGuid().ToString()
        @"
{
    SqlServerName: '$sqlServerName',
    DatabasesRoot: 'Databases'
}
"@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath
        $config | Should -Not -BeNullOrEmpty
        $config.SqlServerName | Should -Be $sqlServerName
    }
    
    It 'should parse connection timeout' {
        @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    ConnectionTimeout: 300
}
"@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath
        $config | Should -Not -BeNullOrEmpty
        $config.ConnectionTimeout | Should -Be 300
    }
    
    It 'should validate connection timeout' {
        @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    ConnectionTimeout: 'blah'
}
"@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'invalid'
    }
    
    It 'should parse command timeout' {
        @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    CommandTimeout: 300
}
"@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath
        $config | Should -Not -BeNullOrEmpty
        $config.CommandTimeout | Should -Be 300
    }
    
    It 'should validate command timeout' {
        @"
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    CommandTimeout: 'blah'
}
"@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'invalid'
    }
    
    It 'should parse rivet config in current directory' {
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
            $config | Should -Not -BeNullOrEmpty
            $config.DatabasesRoot | Should -Be "$tempDir\Databases"
        }
        finally
        {
            Pop-Location
        }
    }
    
    It 'should find all databases' {
        $dbNames = @('One','Three','Two') 
        $dbNames | New-DatabaseDirectory
    
        $config = Get-RivetConfig -Path $rivetConfigPath
        $config | Should -Not -BeNullOrEmpty
        $config.Databases.Count | Should -Be 3
        
        $idx = 0
        $dbNames | ForEach-Object {
            $config.Databases[$idx].Name | Should -Be $_
            $config.Databases[$idx].Root | Should -Be (Join-Path -Path $tempDir -ChildPath "Databases\$_")
            $idx += 1
        }
    }
    
    It 'should ignore databases' {
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
        $config | Should -Not -BeNullOrEmpty
        $config.Databases.Count | Should -Be 1
        $config.Databases[0].Name | Should -Be 'One'
    }
    
    It 'should handle one ignore rule' {
        'One' | New-DatabaseDirectory
    
        @'
{
    SqlServerName: '.\\Test',
    DatabasesRoot: 'Databases',
    IgnoreDatabases: 'One'
}
'@ | Set-RivetConfig
    
        $config = Get-RivetConfig -Path $rivetConfigPath
        $config | Should -Not -BeNullOrEmpty
        $config.Databases.Count | Should -Be 0
    }
    
    It 'should override settings from environment' {
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
        $defaultConfig.SqlServerName | Should -Be '.\Rivet'
        $defaultConfig.DatabasesRoot | Should -Be $databasesRootPath
        $defaultConfig.ConnectionTimeout | Should -Be 15
        $defaultConfig.Databases.Count | Should -Be 0
    
        $uatConfig.SqlServerName | Should -Be 'uatdb\Rivet'
        $uatConfig.DatabasesRoot | Should -Be $uatDatabasesPath
        $uatConfig.ConnectionTimeout | Should -Be 999
        $uatConfig.Databases.Count | Should -Be 1
        $uatConfig.Databases[0].Name | Should -Be 'UatDatabase'
    
        $prodConfig.SqlServerName | Should -Be 'proddb\Rivet'
        $prodConfig.DatabasesRoot | Should -Be $databasesRootPath
        $prodConfig.ConnectionTimeout | Should -Be 15
        $prodConfig.Databases.Count | Should -Be 0
    }
    
    It 'should return explicit databases' {
        $config = Get-RivetConfig -Path $rivetConfigPath -Database 'one','two'
        $config | Should -Not -BeNullOrEmpty
        $config.Databases.Count | Should -Be 2
        $config.Databases[0].Name | Should -Be 'one'
        $config.Databases[0].Root | Should -Be (Join-Path -Path $tempDir -ChildPath "Databases\one")
        $config.Databases[1].Name | Should -Be 'two'
        $config.Databases[1].Root | Should -Be (Join-Path -Path $tempDir -ChildPath "Databases\two")
    }
    
    It 'should return unique databases' {
        $db = [Guid]::NewGuid().ToString()
        $db | New-DatabaseDirectory
    
        $config = Get-RivetConfig -Path $rivetConfigPath -Database $db
        $config | Should -Not -BeNullOrEmpty
        $config.Databases.Count | Should -Be 1
        $config.Databases[0].Name | Should -Be $db
        $config.Databases[0].Root | Should -Be (Join-Path -Path $tempDir -ChildPath "Databases\$db")
    }
    
    It 'should only return explicit databases' {
        $db = [Guid]::NewGuid().ToString()
        $db | New-DatabaseDirectory
    
        $config = Get-RivetConfig -Path $rivetConfigPath -Database 'one'
        $config | Should -Not -BeNullOrEmpty
        $config.Databases.Count | Should -Be 1
        $config.Databases[0].Name | Should -Be 'one'
        $config.Databases[0].Root | Should -Be (Join-Path -Path $tempDir -ChildPath "Databases\one")
    }
    
    It 'should fail if environment missing' {
        $dbName = [Guid]::NewGuid().ToString()
        $dbName | New-DatabaseDirectory
    
        $config = Get-RivetConfig -Path $rivetConfigPath -Environment 'IDoNotExist' -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'Environment "IDoNotExist" not found'
    }
    
    
    It 'should parse target databases' {
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
        ($defaultConfig.Databases | Where-Object { $_.Name -eq 'UatDatabase' }) | Should -BeNullOrEmpty
    
        $db2 = $defaultConfig.Databases | Where-Object { $_.Name -eq 'DB2' }
        $db2 | Should -Not -BeNullOrEmpty
        $db2.Name | Should -Be 'DB2'
        $db2.Root | Should -Be (Join-Path -Path $uatDatabasesPath -ChildPath 'UatDatabase')
        $db2.MigrationsRoot | Should -Be (Join-Path -Path $uatDatabasesPath -ChildPath 'UatDatabase\Migrations')
    
        $db3 = $defaultConfig.Databases | Where-Object { $_.Name -eq 'db3' }
        $db3 | Should -Not -BeNullOrEmpty
        $db3.Name | Should -Be 'db3'
        $db3.Root | Should -Be (Join-Path -Path $uatDatabasesPath -ChildPath 'UatDatabase')
        $db3.MigrationsRoot | Should -Be (Join-Path -Path $uatDatabasesPath -ChildPath 'UatDatabase\Migrations')
    }
    
    It 'should ignore errors from outside' {
        # REGRESSION TEST: If an error from outside exists, fails to return anything
        Write-Error 'fubar!' -ErrorAction SilentlyContinue
        $config = Get-RivetConfig -Path $rivetConfigPath
        $config | Should -Not -BeNullOrEmpty
    }
    
}

Describe 'Get-RivetConfig.when databases have a custom order' {
    Init
    GivenDatabase 'AAA','BBB','CCC','DDD'
    GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "Databases": [ "CCC", "BBB" ]
}
'@
    $config = WhenGettingConfig
    It ('should order databases') {
        $config.Databases.Count | Should -Be 2
        $config.Databases[0].Name | Should -Be 'CCC'
        $config.Databases[1].Name | Should -Be 'BBB'
    }
}

Describe 'Get-RivetConfig.when databases have a custom order with a wild card' {
    Init
    GivenDatabase 'AAA','BBB','CCC','DDD'
    GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "Databases": [ "CCC", "BBB", "*" ]
}
'@
    $config = WhenGettingConfig
    It ('should order databases') {
        $config.Databases.Count | Should -Be 4
        $config.Databases[0].Name | Should -Be 'CCC'
        $config.Databases[1].Name | Should -Be 'BBB'
        $config.Databases[2].Name | Should -Be 'AAA'
        $config.Databases[3].Name | Should -Be 'DDD'
    }
}

Describe 'Get-RivetConfig.when databases have no custom order' {
    Init
    GivenDatabase 'AAA','BBB','CCC','DDD'
    GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases"
}
'@
    $config = WhenGettingConfig
    It ('should order databases') {
        $config.Databases.Count | Should -Be 4
        $config.Databases[0].Name | Should -Be 'AAA'
        $config.Databases[1].Name | Should -Be 'BBB'
        $config.Databases[2].Name | Should -Be 'CCC'
        $config.Databases[3].Name | Should -Be 'DDD'
    }
}

Describe 'Get-RivetConfig.when databases have a custom order but one doesn''t exist' {
    Init
    GivenDatabase 'AAA','BBB','CCC','DDD'
    GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "Databases": [ "CCC", "BBB", "ZZZ" ]
}
'@
    $config = WhenGettingConfig -ErrorAction SilentlyContinue
    It ('should order databases') {
        $config.Databases.Count | Should -Be 2
        $config.Databases[0].Name | Should -Be 'CCC'
        $config.Databases[1].Name | Should -Be 'BBB'
    }
    $errorMessage = Join-Path -Path $config.DatabasesRoot -ChildPath 'ZZZ'
    $Global:Error | Should -Match "database named ""ZZZ"" at ""$($errorMessage.replace('\','\\'))"" does not exist"
}

Describe 'Get-RivetConfig.when plugins root has a wildcard' {
    It 'should resolve to actual path' {
        Init
        GivenDatabase 'Config'
        GivenDirectory 'Extensions\0.1.0\Plugins'
        GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "PluginPaths": "Extensions\\*\\Plugins"
}
'@
        $config = WhenGettingConfig
        $config.PluginPaths | Should -Be (Join-Path -Path $tempDir -ChildPath 'Extensions\0.1.0\Plugins')
    }
}

Describe 'Get-RivetConfig.when plugins root has a wildcard that points to multiple paths' {
    It 'should fail and not resolve' {
        Init
        GivenDatabase 'Config'
        GivenDirectory 'Extensions\0.1.0\Plugins'
        GivenDirectory 'Extensions\0.2.0\Plugins'
        GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "PluginPaths": "Extensions\\*\\Plugins"
}
'@
        $config = WhenGettingConfig -ErrorAction SilentlyContinue
        $config | Should -BeNullOrEmpty
        $Global:Error | Should -Not -BeNullOrEmpty
        $Global:Error | Should -Match 'resolves\ to\ multiple\ items'
    }
}

Describe 'Get-RivetConfig.when there are multiple plugin paths' {
    It 'should set PluginPaths property to list of paths' {
        Init
        GivenDirectory 'PluginOne'
        GivenDirectory 'PluginTwo'
        GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "PluginPaths": [ "PluginOne", "PluginTwo" ]  
}
'@
        $config = WhenGettingConfig
        $config.PluginPaths.Count | Should -Be 2
        $root = $rivetConfigPath | Split-Path -Parent
        $config.PluginPaths[0] | Should -Be (Join-Path -Path $root -ChildPath 'PluginOne')
        $config.PluginPaths[1] | Should -Be (Join-Path -Path $root -ChildPath 'PluginTwo')
    }
}

Describe 'Get-RivetConfig.when user has multiple plugin modules' {
    It 'should set PluginModules setting' {
        Init
        GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "PluginModules": [ "RivetSamples", "TestPlugins" ]
}
'@
        $config = WhenGettingConfig
        ,$config.PluginModules | Should -BeOfType ([string[]])
        $config.PluginModules | Should -Be @('RivetSamples','TestPlugins')
    }
}

Describe 'Get-RivetConfig.when user has single plugin module' {
    It 'should set PluginModules setting' {
        Init
        GivenConfig @'
{
    "SqlServerName": ".\\Rivet",
    "DatabasesRoot": "Databases",
    "PluginModules": "RivetSamples"
}
'@
        $config = WhenGettingConfig
        ,$config.PluginModules | Should -BeOfType ([string[]])
        $config.PluginModules | Should -Be @('RivetSamples')
    }
}
