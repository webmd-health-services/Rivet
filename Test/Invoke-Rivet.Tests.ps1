
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function Assert-OperationsReturned
    {
        param(
            [Object[]] $Operation
        )

        $Operation | Should -Not -BeNullOrEmpty
    }

    function Init
    {
        param(
            $PluginPath
        )

        Start-RivetTest -PluginPath $PluginPath
        $Global:Error.Clear()
    }

    function Reset
    {
        param(
            [string[]]
            $Plugin
        )

        Stop-RivetTest
        Remove-Module -Name $Plugin
    }

    }

Describe 'Invoke-Rivet' {
    BeforeEach {
        Start-RivetTest -IgnoredDatabase 'Ignored'
        $Global:Error.Clear()
    }

    AfterEach {
        try
        {
            Stop-RivetTest
        }
        catch
        {
        }
        Clear-TestDatabase -Name $RTDatabase2Name
    }

    It 'should create database' {
        Remove-RivetTestDatabase

        $query = 'select 1 from sys.databases where name=''{0}''' -f $RTDatabaseName

        (Invoke-RivetTestQuery -Query $query -Master -AsScalar) | Should -BeNullOrEmpty

        @'
    function Push-Migration
    {
        Add-Schema 'fubar'
    }

    function Pop-Migration
    {
        Remove-Schema 'fubar'
    }
'@ | New-TestMigration -Name 'CreateDatabase'

        $result = Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        $Global:Error.Count | Should -Be 0
        Assert-OperationsReturned $result

        (Invoke-RivetTestQuery -Query $query -Master -AsScalar) | Should -Be 1
    }

    It 'should apply migrations to duplicate database' {
        $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
        $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $RTDatabase2Name ) }
        $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

        @'
    function Push-Migration
    {
        Add-Schema 'TargetDatabases'
    }

    function Pop-Migration
    {
        Remove-Schema 'TargetDatabases'
    }
'@ | New-TestMigration -Name 'TargetDatabases' -Database $RTDatabaseName

        $result = Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        $Global:Error.Count | Should -Be 0
        Assert-OperationsReturned $result

        Assert-Schema -Name 'TargetDatabases'
        Assert-Schema -Name 'TargetDatabases' -DatabaseName $RTDatabase2Name
    }

    It 'should create target databases' {
        Remove-RivetTestDatabase
        Remove-RivetTestDatabase -Name $RTDatabase2Name

        $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
        $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $RTDatabase2Name ) }
        $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

        Remove-Item -Path $RTDatabaseMigrationRoot -Recurse

        $result = Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        $Global:Error.Count | Should -Be 0
        (Test-Database) | Should -BeTrue
        (Test-Database $RTDatabase2Name) | Should -BeTrue
    }

    It 'should write error if migrating ignored database' {
        Push-Location -Path (Split-Path -Parent -Path $RTConfigFilePath)
        try
        {
            & $RTRivetPath -Push -Database 'Ignored' -ErrorAction SilentlyContinue
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match ([regex]::Escape($RTConfigFilePath))
        }
        finally
        {
            Pop-Location
        }
    }

    It 'should prohibit reserved rivet migration IDs' {
        $startedAt = Get-Date
        $file = @'
    function Push-Migration
    {
        Add-Schema 'fubar'
    }

    function Pop-Migration
    {
        Remove-Schema 'fubar'
    }
'@ | New-TestMigration -Name 'HasReservedID' -Database $RTDatabaseName

        $file | Should -Not -BeNullOrEmpty
        $file = Rename-Item -Path $file -NewName ('00010100999999_HasReservedID.ps1') -PassThru

        { Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push } |
            Should -Throw '*reserved*'
        (Test-Schema -Name 'fubar') | Should -BeFalse

        $Global:Error.Clear()
        Rename-Item -Path $file -NewName ('00010101000000_HasReservedID.ps1')
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        $Global:Error.Count | Should -Be 0
        Assert-Schema -Name 'fubar'
    }

    It 'handles connection failure' {
        $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
        $originalSqlServerName = $config.SqlServerName
        $config.SqlServerName = '.\IDoNotExist'
        $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

        try
        {
            { Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push } |
                Should -Throw '*network-related or instance-specific error*'
        }
        finally
        {
            $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
            $config.SqlServerName = $originalSqlServerName
            $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath
        }
    }

    It 'should create multiple migrations' {
        $m = Invoke-Rivet -New -Name 'One','Two' -ConfigFilePath $RTConfigFilePath
        try
        {
            $Global:Error | Should -BeNullOrEmpty
            ,$m | Should -BeOfType ([object[]])
            $m[0].Name | Should -BeLike '*_One.ps1'
            $m[1].Name | Should -BeLike '*_Two.ps1'
        }
        finally
        {
            $m | Remove-Item
        }
    }

    It 'should push multiple migrations' {
        $m = @( 'One', 'Two', 'Three' ) |
                ForEach-Object {
                                    @'
    function Push-Migration { Invoke-Ddl 'select 1' }
    function Pop-Migration { Invoke-Ddl 'select 1' }
'@ | New-TestMigration -Name $_
                }
        [Rivet.OperationResult[]]$result = Invoke-Rivet -Name 'One','Three' -ConfigFilePath $RTConfigFilePath -Push
        Assert-OperationsReturned $result
        $result[0].Migration.Name | Should -Be 'One'
        $result[1].Migration.Name | Should -Be 'Three'
    }

    It 'should pop multiple migrations' {
        $m = @( 'One', 'Two', 'Three' ) |
                ForEach-Object {
                                    @'
    function Push-Migration { Invoke-Ddl 'select 1' }
    function Pop-Migration { Invoke-Ddl 'select 1' }
'@ | New-TestMigration -Name $_
                }
        Invoke-Rivet -Name 'One','Three' -ConfigFilePath $RTConfigFilePath -Push
        [Rivet.OperationResult[]]$result = Invoke-Rivet -Pop -Name 'One','Three' -ConfigFilePath $RTConfigFilePath
        Assert-OperationsReturned $result
        $result[0].Migration.Name | Should -Be 'Three'
        $result[1].Migration.Name | Should -Be 'One'
    }

    It 'should drop all databases given -DropDatabase with no databases specified' {
        Remove-RivetTestDatabase
        Remove-RivetTestDatabase -Name $RTDatabase2Name

        $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
        $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $RTDatabase2Name ) }
        $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

        # Create databases first
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        $Global:Error.Count | Should -Be 0
        (Test-Database) | Should -BeTrue
        (Test-Database $RTDatabase2Name) | Should -BeTrue

        # Now drop the databases
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -DropDatabase -Force
        $Global:Error.Count | Should -Be 0
        (Test-Database) | Should -BeFalse
        (Test-Database $RTDatabase2Name) | Should -BeFalse
    }

    It 'should drop a specific database given -DropDatabase with a database name' {
        Remove-RivetTestDatabase
        Remove-RivetTestDatabase -Name $RTDatabase2Name

        $config = Get-Content -Raw -Path $RTConfigFilePath | ConvertFrom-Json
        $config | Add-Member -MemberType NoteProperty -Name 'TargetDatabases' -Value @{ $RTDatabaseName = @( $RTDatabaseName, $RTDatabase2Name ) }
        $config | ConvertTo-Json | Set-Content -Path $RTConfigFilePath

        # Create databases first
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        $Global:Error.Count | Should -Be 0
        (Test-Database) | Should -BeTrue
        (Test-Database $RTDatabase2Name) | Should -BeTrue

        # Now drop the database
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -DropDatabase -Force -Database 'RivetTest2'
        $Global:Error.Count | Should -Be 0
        (Test-Database) | Should -BeTrue
        (Test-Database $RTDatabase2Name) | Should -BeFalse
    }

    It 'should do nothing when given -DropDatabase with a database name that doesn''t exist' {
        Remove-RivetTestDatabase
        # Check that database doesn't exist first
        (Test-Database) | Should -BeFalse

        # Now drop the database
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -DropDatabase -Force -Database 'RivetTest'
        $Global:Error.Count | Should -Be 0
        (Test-Database) | Should -BeFalse
    }
}

Describe 'Invoke-Rivet' {
    BeforeEach { Init -PluginPath 'InvokeRivetTestPlugin' }
    AfterEach { Reset -Plugin 'InvokeRivetTestPlugin' }
    It 'loads plugins' {
        GivenFile 'InvokeRivetTestPlugin\InvokeRivetTestPlugin.psm1' @'
function MyPlugin
{
}
'@
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        Get-Module -Name 'InvokeRivetTestPlugin' | Should -Not -BeNullOrEmpty
    }
}

Describe 'Invoke-Rivet' {
    BeforeEach { Init -PluginPath 'InvokeRivetTestPlugin','InvokeRivetTestPlugin2' }
    AfterEach { Reset -Plugin 'InvokeRivetTestPlugin','InvokeRivetTestPlugin2' }
    It 'loads multiple plugins' {
        GivenFile 'InvokeRivetTestPlugin\InvokeRivetTestPlugin.psm1' @'
function MyPlugin
{
}
'@
        GivenFile 'InvokeRivetTestPlugin2\InvokeRivetTestPlugin2.psm1' @'
function MyPlugin2
{
}
'@
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        Get-Module -Name 'InvokeRivetTestPlugin' | Should -Not -BeNullOrEmpty
        Get-Module -Name 'InvokeRivetTestPlugin2' | Should -Not -BeNullOrEmpty
    }
}

Describe 'Invoke-Rivet' {
    BeforeEach { Init -PluginPath 'InvokeRivetTestPlugin' }
    AfterEach { Reset -Plugin 'InvokeRivetTestPlugin' }
    It 'reloads plugins' {
        GivenFile 'InvokeRivetTestPlugin\InvokeRivetTestPlugin.psm1' @'
function MyPlugin
{
}
'@
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        Get-Module -Name 'InvokeRivetTestPlugin' | Should -Not -BeNullOrEmpty
        Get-Command -Name 'MyPlugin' | Should -Not -BeNullOrEmpty

        # Now, change the module.
        GivenFile 'InvokeRivetTestPlugin\InvokeRivetTestPlugin.psm1' @'
function NewMyPlugin
{
}
'@
        Invoke-Rivet -ConfigFilePath $RTConfigFilePath -Database $RTDatabaseName -Push
        Get-Module -Name 'InvokeRivetTestPlugin' | Should -Not -BeNullOrEmpty
        Get-Command -Name 'MyPlugin' -ErrorAction Ignore | Should -BeNullOrEmpty
        Get-Command -Name 'NewMyPlugin' | Should -Not -BeNullOrEmpty
    }
}

