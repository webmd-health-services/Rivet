
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-RowVersionColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create row version column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            RowVersion 'id'
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateRowVersionColumn'

        Invoke-RTRivet -Push 'CreateRowVersionColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'timestamp' -TableName 'Foobar' -NotNull
    }


    It 'should create row version column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            RowVersion 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateRowVersionColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateRowVersionColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'timestamp' -TableName 'Foobar' -NotNull
    }
}
