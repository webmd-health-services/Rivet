
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-DateColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create date column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Date 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateColumn'

        Invoke-RTRivet -Push 'CreateDateColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Date' -TableName 'Foobar'
    }

    It 'should create date column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Date 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateColumnWithSparse'

        Invoke-RTRivet -Push 'CreateDateColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Date' -TableName 'Foobar' -Sparse
    }

    It 'should create date column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Date 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateDateColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateDateColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Date' -TableName 'Foobar' -NotNull
    }
}
