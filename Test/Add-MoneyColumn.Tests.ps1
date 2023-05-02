
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-MoneyColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create money column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Money 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateMoneyColumn'

        Invoke-RTRivet -Push 'CreateMoneyColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Money' -TableName 'Foobar'
    }

    It 'should create money column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Money 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateMoneyColumnWithSparse'

        Invoke-RTRivet -Push 'CreateMoneyColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Money' -TableName 'Foobar' -Sparse
    }

    It 'should create money column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Money 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateMoneyColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateMoneyColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Money' -TableName 'Foobar' -NotNull
    }
}
