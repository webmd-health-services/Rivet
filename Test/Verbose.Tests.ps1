
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Verbose' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'verbose switch' {

        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime2 'id' -Precision 6
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'VerboseSwitch'

        Invoke-RTRivet -Push 'VerboseSwitch' -Verbose
    }
}
