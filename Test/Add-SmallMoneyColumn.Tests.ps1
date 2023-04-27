
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-SmallMoneyColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create small money column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SmallMoney 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSmallMoneyColumn'

        Invoke-RTRivet -Push 'CreateSmallMoneyColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar'
    }

    It 'should create small money column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SmallMoney 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSmallMoneyColumnWithSparse'

        Invoke-RTRivet -Push 'CreateSmallMoneyColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar' -Sparse
    }

    It 'should create small money column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SmallMoney 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSmallMoneyColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateSmallMoneyColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar' -NotNull
    }
}
