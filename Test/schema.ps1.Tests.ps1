

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function GivenPlugins
    {
        function Global:StopBeforeOpLoad
        {
            [CmdletBinding()]
            [Rivet.Plugin([Rivet.Events]::BeforeOperationLoad)]
            param(
                $Operation,
                $Migration
            )
            throw 'stop before operation load!'
        }

        function Global:StopAfterOpLoad
        {
            [CmdletBinding()]
            [Rivet.Plugin([Rivet.Events]::AfterOperationLoad)]
            param(
                $Operation,
                $Migration
            )
            throw 'stop after operation load!'
        }

        function Global:StopAfterMigrationLoad
        {
            [CmdletBinding()]
            [Rivet.Plugin([Rivet.Events]::AfterMigrationLoad)]
            param(
                $Operation,
                $Migration
            )
            throw 'stop after migration load!'
        }
    }

    function ThenBaselineMigration
    {
        param(
            [switch] $Not,

            [Parameter(Mandatory)]
            [switch] $Applied
        )

        $rowsmigration = Get-MigrationInfo -Force
        $rowsmigration | Should -Not -BeNullOrEmpty

        $migration = $rowsmigration | Where-Object 'ID' -eq 10000000000
        if ($Not)
        {
            $migration | Should -BeNullOrEmpty
        }
        else
        {
            $migration | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'schemaPs1' {
    BeforeEach {
        Remove-RivetTestDatabase
        Start-RivetTest
        $Global:Error.Clear()
    }

    AfterEach {
        Remove-Item -Path 'function:StopBeforeOpLoad' -ErrorAction Ignore
        Remove-Item -Path 'function:StopAfterOpLoad' -ErrorAction Ignore
        Remove-Item -Path 'function:StopAFterMigrationLoad' -ErrorAction Ignore
        Remove-RivetTestDatabase
    }

    It 'is applied when pushing' {
        { Invoke-RTRivet -Push } | Should -Not -Throw
        ThenBaselineMigration -Not -Applied

        @"
function Push-Migration
{
    Add-Table 'SchemaPs1' {
        int 'ID'
    }
}

function Pop-Migration
{
    Remove-Table 'SchemaPs1'
}
"@ | New-TestMigration -AsCheckpoint

        { Invoke-RTRivet -Push } | Should -Not -Throw
        $Global:Error | Should -BeNullOrEmpty
        ThenBaselineMigration -Applied
    }

    It 'is never popped' {
        @"
function Push-Migration
{
    Add-Table 'SchemaPs1' {
        int 'ID'
    }
}

function Pop-Migration
{
    Remove-Table 'SchemaPs1'
}
"@ | New-TestMigration -AsCheckpoint

        { Invoke-RTRivet -Push } | Should -Not -Throw
        { Invoke-RTRivet -Pop -All } | Should -Not -Throw
        $Global:Error | Should -BeNullOrEmpty
        ThenBaselineMigration -Applied
    }

    It 'causes included migrations to not get pushed' {
        $migration = @'
function Push-Migration
{
    throw 'i should not be run'
}

function Pop-Migration
{
    throw 'i should not be run'
}
'@ | New-TestMigration -Named 'One'

    @"
function Push-Migration
{
    Add-Table 'SchemaPs1' {
        int 'ID'
    }

    Add-Row -SchemaName 'rivet' -TableName 'Migrations' -Column @{
        ID = '$($migration.MigrationID)';
        Name = '$($migration.Name)';
        Who = '$([Environment]::UserName)';
        ComputerName = '$([Environment]::MachineName)';
        AtUtc = '$([DateTime]::UtcNow)';
    }
}

function Pop-Migration
{
    Remove-Table 'SchemaPs1'
}
"@ | New-TestMigration -AsCheckpoint

        { Invoke-RTRivet -Push } | Should -Not -Throw
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'is immune to plug-ins' {
        GivenPlugins

        @"
        function Push-Migration
        {
            Add-Table 'NoPluginsPlease' {
                int 'ID'
            }
            Remove-Table 'NoPluginsPlease'
        }

        function Pop-Migration
        {
            Remove-Table 'NoPluginsPlease'
        }
"@ | New-TestMigration -AsCheckpoint

        Invoke-RTRivet -Push

        $Global:Error | Should -BeNullOrEmpty
    }

    It 'is only applied to an empty database' {
        @"
function Push-Migration
{
    Add-Table 'SchemaPs1' {
        int 'ID'
    }
}

function Pop-Migration
{
    Remove-Table 'SchemaPs1'
}
"@ | New-TestMigration -Named 'One'

        { Invoke-RTRivet -Push } | Should -Not -Throw
        ThenBaselineMigration -Not -Applied

@"
function Push-Migration
{
    Add-Table 'SchemaPs1' {
        int 'ID'
    }
}

function Pop-Migration
{
    Remove-Table 'SchemaPs1'
}
"@ | New-TestMigration -AsCheckpoint

        { Invoke-RTRivet -Push } | Should -Not -Throw
        ThenBaselineMigration -Not -Applied
    }
}
