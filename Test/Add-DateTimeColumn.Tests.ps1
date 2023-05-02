
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-DateTimeColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create date time column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTimeColumn'

        Invoke-RTRivet -Push 'CreateDateTimeColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTime' -TableName 'Foobar'
    }

    It 'should create date time2 column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTimeColumnWithSparse'

        Invoke-RTRivet -Push 'CreateDateTimeColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTime' -TableName 'Foobar' -Sparse
    }

    It 'should create date time2 column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTimeColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateDateTimeColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTime' -TableName 'Foobar' -NotNull
    }
}
