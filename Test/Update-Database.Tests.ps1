
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

& (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

Describe 'Update-Database' {
    BeforeEach {
        $Global:Error.Clear()
        Start-RivetTest
    }
    
    AfterEach {
        Stop-RivetTest
    }
    
    It 'should allow long migration names' {
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
        (Test-Table 'Foobar') | Should -Be $true
    }

}
