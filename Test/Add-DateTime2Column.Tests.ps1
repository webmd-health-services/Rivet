
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-DateTime2Column' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create date time2 column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime2 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTime2Column'

        Invoke-RTRivet -Push 'CreateDateTime2Column'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -Scale 7
    }

    It 'should create date time2 column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime2 'id' 6 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTime2ColumnWithSparse'

        Invoke-RTRivet -Push 'CreateDateTime2ColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -Sparse -Scale 6
    }

    It 'should create date time2 column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            DateTime2 'id' 6 -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateTime2ColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateDateTime2ColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -NotNull -Scale 6
    }
}
