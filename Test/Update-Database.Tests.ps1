
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Update-Database' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Invoke-RTRivet -Pop -All
        Stop-RivetTest
    }

    It 'allows long migration names' {
        $migrationPathLength = $RTDatabaseMigrationRoot.Length
        # remove length of the separator, timestamp, underscore and extension
        $name = 'a' * (259 - $migrationPathLength - 1 - 14 - 1 - 4)

        @'
    function Push-Migration
    {
        Add-Table Foobar {
            BigInt ID
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name $name

        Invoke-RTRivet -Push
        $Global:Error.Count | Should -Be 0
        (Test-Table 'Foobar') | Should -BeTrue
    }

    It 'does not parse already applied migrations' {
        $migrationContent = @'
function Push-Migration
{
    Add-Schema 'test'
}

function Pop-Migration
{
    Remove-Schema 'test'
}
'@
        $migration = GivenMigration -Named 'WillBeUnparsable' $migrationContent
        WhenMigrating 'WillBeUnparsable'
        '{' | Set-Content -Path $migration.FullName
        WhenMigrating 'WillBeUnparsable'
        $Global:Error | Should -BeNullOrEmpty
        $migrationContent | Set-Content -Path $migration.FullName
    }
}