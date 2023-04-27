
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'ScriptStackTrace' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should display script stack trace' {
        $m = @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Binary 'id' -TestingScriptStackTrace 'BogusString'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'BogusMigration'

        try
        {
            Invoke-RTRivet -Push 'BogusMigration' -ErrorAction SilentlyContinue
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'TestingScriptStackTrace'
            $Global:Error.Count | Should -BeGreaterThan 0
            $Global:Error[0] | Should -Match 'STACKTRACE'
        }
        finally
        {
            Remove-Item $m
        }
    }
}
