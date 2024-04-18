
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
    Remove-Item -Path 'alias:GivenMigration'

    $script:dbName = 'Invoke-Rivet'
    $script:db2Name = 'Invoke-Rivet2'
    $script:virtualDbName = 'Invoke-RivetISHOULDNOTEXIST'
    $script:testDirPath = $null
    $script:testNum = 0
    $script:sqlServerName = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Server.txt') -ReadCount 1

    function Assert-OperationsReturned
    {
        param(
            [Object[]] $Operation
        )

        $Operation | Should -Not -BeNullOrEmpty
    }

    function GivenDirectory
    {
        param(
            [String] $Named
        )

        $path = Join-Path $script:testDirPath -ChildPath $Named
        if (-not (Test-Path -Path $path))
        {
            New-Item -Path $path -ItemType Directory
        }
    }

    function GivenMigration
    {
        param(
            [Parameter(Mandatory, Position=0)]
            [String] $Named,

            [Parameter(Mandatory, Position=1)]
            [String] $WithContent,

            [string] $ForDatabase = $script:dbName,

            [UInt64] $WithID
        )

        $optionalArgs = @{}
        if ($WithID)
        {
            $optionalArgs['WithID'] = $WithID
        }

        $WithContent | New-TestMigration -Name $Named `
                                         -ConfigFilePath $script:rivetJsonPath `
                                         -DatabaseName $ForDatabase `
                                         @optionalArgs
    }

    function ThenOperationsReturned
    {
        Assert-OperationsReturned -Operation $script:result
    }

    function WhenRivetInvoked
    {
        [CmdletBinding()]
        param(
            [hashtable] $WithArgs
        )

        if (-not $WithArgs.ContainsKey('Database'))
        {
            $WithArgs['Database'] = $script:dbName
        }

        $script:result = Invoke-Rivet -ConfigFilePath $script:rivetJsonPath @WithArgs
    }
}

Describe 'Invoke-Rivet' {
    BeforeAll {
        Remove-RivetTestDatabase -Name $script:dbName
        Remove-RivetTestDatabase -Name $script:db2Name
    }

    BeforeEach {
        $script:testDirPath = Join-Path -Path $TestDrive -ChildPath ($script:testNum++)
        New-Item -Path $script:testDirPath -ItemType Directory
        $script:migrations = @()
        $script:rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -Database $script:dbName -PassThru
        $script:result = $null
        $Global:Error.Clear()
    }

    It 'should create database' {
        $query = "select 1 from sys.databases where name='${script:dbName}'"

        (Invoke-RivetTestQuery -Query $query -Master -AsScalar) | Should -BeNullOrEmpty

        GivenMigration 'CreateDatabase' @'
            function Push-Migration
            {
                Add-Schema 'fubar'
            }

            function Pop-Migration
            {
                Remove-Schema 'fubar'
            }
'@
        WhenRivetInvoked -WithArgs @{ Push = $true }
        ThenError -IsEmpty
        ThenOperationsReturned

        (Invoke-RivetTestQuery -Query $query -Master -AsScalar) | Should -Be 1
    }

    Context 'TargetDatabases' {
        BeforeEach {
            Remove-RivetTestDatabase -Name $script:virtualDbName
            Remove-RivetTestDatabase -Name $script:dbName
            Remove-RivetTestDatabase -Name $script:db2Name
            $script:rivetJsonPath =
                GivenRivetJson -In $script:testDirPath `
                               -Database $script:dbName `
                               -TargetDatabase @{ $script:virtualDbName = @($script:dbName,$script:db2Name) } `
                               -PassThru
        }

        It 'should apply migrations to duplicate database' {
            GivenMigration 'TargetDatabases' -ForDatabase $script:virtualDbName @'
                function Push-Migration
                {
                    Add-Schema 'TargetDatabases'
                }

                function Pop-Migration
                {
                    Remove-Schema 'TargetDatabases'
                }
'@

            WhenRivetInvoked -WithArgs @{ Push = $true ; Database = $script:virtualDbName }
            ThenError -IsEmpty
            ThenOperationsReturned
            Assert-Schema -Name 'TargetDatabases' -DatabaseName $script:dbName
            Assert-Schema -Name 'TargetDatabases' -DatabaseName $script:db2Name
        }

        It 'should create target databases' {
            WhenRivetInvoked -WithArgs @{ Push = $true ; Database = $script:virtualDbName }
            ThenError -IsEmpty
            (Test-Database $script:virtualDbName) | Should -BeFalse
            (Test-Database $script:dbName) | Should -BeTrue
            (Test-Database $script:db2Name) | Should -BeTrue
        }

        It 'drops virtual databases' {
            WhenRivetInvoked -WithArgs @{ Push = $true ; Database = $script:virtualDbName }
            ThenError -IsEmpty
            (Test-Database $script:virtualDbName) | Should -BeFalse
            (Test-Database $script:dbName) | Should -BeTrue
            (Test-Database $script:db2Name) | Should -BeTrue

            # Now drop the databases
            WhenRivetInvoked -WithArgs @{ DropDatabase = $true ; Database = $script:virtualDbName ; Force = $true }
            ThenError -IsEmpty
            (Test-Database $script:virtualDbName) | Should -BeFalse
            (Test-Database $script:dbName) | Should -BeFalse
            (Test-Database $script:db2Name) | Should -BeFalse
        }

    }

    It 'should write error if migrating ignored database' {
        $script:rivetJsonPath =
            GivenRivetJson -In $script:testDirPath -Database $script:dbName -IgnoredDatabase 'Ignored' -PassThru
        WhenRivetInvoked -WithArgs @{ Push = $true ; Database = 'Ignored' } -ErrorAction SilentlyContinue
        ThenError -Matches 'database is on the ignore list'
    }

    It 'should prohibit reserved rivet migration IDs' {
        GivenMigration 'HasReservedID' -WithID 10100999999 @'
            function Push-Migration
            {
                Add-Schema 'fubar'
            }

            function Pop-Migration
            {
                Remove-Schema 'fubar'
            }
'@

        { WhenRivetInvoked -WithArgs @{ Push = $true } } | Should -Throw '*reserved*'
        (Test-Schema -Name 'fubar') | Should -BeFalse
    }

    It 'handles connection failure' {
        $script:rivetJsonPath = GivenRivetJson -In $script:testDirPath `
                                               -Database $script:dbName `
                                               -SqlServerName '.\IDoNotExist' `
                                               -ConnectionTimeout 1 `
                                               -PassThru
        { WhenRivetInvoked -WithArgs @{ Push = $true } } |
            Should -Throw '*network-related or instance-specific error*'
    }

    It 'should create multiple migrations' {
        WhenRivetInvoked -WithArgs @{ New = $true ; Name = 'One', 'Two' }
        ThenError -IsEmpty
        ,$script:result | Should -BeOfType ([object[]])
        $script:result[0].Name | Should -BeLike '*_One.ps1'
        $script:result[1].Name | Should -BeLike '*_Two.ps1'
    }

    It 'should push multiple migrations' {
        # Make sure database initialized.
        WhenRivetInvoked -WithArgs @{ Push = $true }
        foreach ($name in @( 'One', 'Two', 'Three' ))
        {
            GivenMigration $name @'
    function Push-Migration { Invoke-Ddl 'select 1' }
    function Pop-Migration { Invoke-Ddl 'select 1' }
'@
        }
        WhenRivetInvoked -WithArgs @{ Push = $true ; Name = 'One', 'Three' }
        ThenOperationsReturned
        $script:result[0].Migration.Name | Should -Be 'One'
        $script:result[1].Migration.Name | Should -Be 'Three'
    }

    It 'should pop multiple migrations' {
        foreach ($name in @( 'One', 'Two', 'Three' ))
        {
            GivenMigration $name @'
    function Push-Migration { Invoke-Ddl 'select 1' }
    function Pop-Migration { Invoke-Ddl 'select 1' }
'@
        }
        WhenRivetInvoked -WithArgs @{ Push = $true ; Name = 'One', 'Three' }
        WhenRivetInvoked -WithArgs @{ Pop = $true ; Name = 'One', 'Three' }
        ThenOperationsReturned
        $script:result[0].Migration.Name | Should -Be 'Three'
        $script:result[1].Migration.Name | Should -Be 'One'
    }

    Context '-DropDatabase' {
        BeforeEach {
            Remove-RivetTestDatabase -Name $script:dbName
            Remove-RivetTestDatabase -Name $script:db2Name
        }

        It 'drops specific database' {
            $script:rivetJsonPath =
                GivenRivetJson -In $script:testDirPath -Database $script:dbName, $script:db2Name -PassThru
            WhenRivetInvoked -WithArgs @{ Push = $true ; Database = $script:dbName,$script:db2Name }
            ThenError -IsEmpty
            (Test-Database $script:dbName) | Should -BeTrue
            (Test-Database $script:db2Name) | Should -BeTrue

            # Now drop the database
            WhenRivetInvoked -WithArgs @{ DropDatabase = $true ; Database = $script:db2Name ; Force = $true }
            ThenError -IsEmpty
            (Test-Database $script:dbName) | Should -BeTrue
            (Test-Database $script:db2Name) | Should -BeFalse
        }

        It 'handles non existent database' {
            # Check that database doesn't exist first
            (Test-Database $script:dbName) | Should -BeFalse

            # Now drop the database
            WhenRivetInvoked -WithArgs @{ DropDatabase = $true ; Database = $script:dbName ; Force = $true}
            ThenError -IsEmpty
            (Test-Database $script:dbName) | Should -BeFalse
        }
    }

    Context 'Plugins' {
        AfterEach {
            Get-Module -Name 'InvokeRivetTestPlugin*' | Remove-Module -Force
        }

        It 'loads single plugin' {
            GivenFile 'InvokeRivetTestPlugin1\InvokeRivetTestPlugin1.psm1' -In $script:testDirPath @'
function MyPlugin1
{
}
'@
            $rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -PluginPath 'InvokeRivetTestPlugin1' -PassThru
            Invoke-Rivet -ConfigFilePath $rivetJsonPath -Database $script:dbName -Push
            Get-Module -Name 'InvokeRivetTestPlugin1' | Should -Not -BeNullOrEmpty
            Get-Command -Name 'MyPlugin1' | Should -Not -BeNullOrEmpty
        }

        It 'loads multiple plugins' {
            GivenFile 'InvokeRivetTestPlugin2\InvokeRivetTestPlugin2.psm1' -In $script:testDirPath @'
function MyPlugin2
{
}
'@
            GivenFile 'InvokeRivetTestPlugin3\InvokeRivetTestPlugin3.psm1' -In $script:testDirPath @'
function MyPlugin3
{
}
'@
            $rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath `
                                                -PluginPath 'InvokeRivetTestPlugin2', 'InvokeRivetTestPlugin3' `
                                                -PassThru
            Invoke-Rivet -ConfigFilePath $rivetJsonPath -Database $script:dbName -Push
            Get-Module -Name 'InvokeRivetTestPlugin2' | Should -Not -BeNullOrEmpty
            Get-Command -Name 'MyPlugin2' | Should -Not -BeNullOrEmpty
            Get-Module -Name 'InvokeRivetTestPlugin3' | Should -Not -BeNullOrEmpty
            Get-Command -Name 'MyPlugin3' | Should -Not -BeNullOrEmpty
        }

        It 'reloads plugins' {
            GivenFile 'InvokeRivetTestPlugin4\InvokeRivetTestPlugin4.psm1' -In $script:testDirPath @'
function MyPlugin4
{
}
'@
            $rivetJsonPath = GivenRivetJsonFile -In $script:testDirPath -PluginPath 'InvokeRivetTestPlugin4' -PassThru
            Invoke-Rivet -ConfigFilePath $rivetJsonPath -Database $script:dbName -Push
            Get-Module -Name 'InvokeRivetTestPlugin4' | Should -Not -BeNullOrEmpty
            Get-Command -Name 'MyPlugin4' | Should -Not -BeNullOrEmpty

            # Now, change the module.
            GivenFile 'InvokeRivetTestPlugin4\InvokeRivetTestPlugin4.psm1' -In $script:testDirPath @'
function MyPlugin5
{
}
'@
            Invoke-Rivet -ConfigFilePath $rivetJsonPath -Database $script:dbName -Push
            Get-Module -Name 'InvokeRivetTestPlugin4' | Should -Not -BeNullOrEmpty
            Get-Command -Name 'MyPlugin4' -ErrorAction Ignore | Should -BeNullOrEmpty
            Get-Command -Name 'MyPlugin5' | Should -Not -BeNullOrEmpty
        }
    }
}

