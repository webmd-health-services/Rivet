
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-NVarCharColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create n var char column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NVarChar 'id' -Max
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateNVarCharColumn'

        Invoke-RTRivet -Push 'CreateNVarCharColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -Max
    }

    It 'should create n var char column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NVarChar 'id' 50 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateNVarCharColumnWithSparse'

        Invoke-RTRivet -Push 'CreateNVarCharColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -Sparse -Size 50
    }

    It 'should create n var char column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NVarChar 'id' -Max -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateNVarCharColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateNVarCharColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull -Max
    }

    It 'should create n var char column with size collation' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NVarChar 'id' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'ShouldCreateNVarCharColumnWithSizeCollation'

        Invoke-RTRivet -Push 'ShouldCreateNVarCharColumnWithSizeCollation'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NVarChar' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}
