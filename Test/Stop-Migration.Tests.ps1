
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Stop-Migration' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should prevent migration from popping' {
        $m = @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }

    function Pop-Migration
    {
        Stop-Migration -Message 'This migration can''t be reversed. Sorry!'
    }
'@ | New-TestMigration -Name 'AddRowGuidCol'

        Invoke-RTRivet -Push

        $count = Measure-Migration
        try
        {
            { Invoke-RTRivet -Pop -ErrorAction SilentlyContinue } | Should -Throw '*can''t be reversed*'
            (Measure-Migration) | Should -Be $count
        }
        finally
        {
            @'
    function Push-Migration
    {
        Invoke-Ddl 'select 1'
    }

    function Pop-Migration
    {
        Invoke-Ddl 'select 1'
    }
'@ | Set-Content -Path $m.FullName
        }
    }
}
