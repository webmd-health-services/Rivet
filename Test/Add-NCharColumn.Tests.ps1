
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-NCharColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create n char column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NChar 'id' 30
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateNCharColumn'

        Invoke-RTRivet -Push 'CreateNCharColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NChar' -TableName 'Foobar'
    }

    It 'should create n char column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NChar 'id' 30 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateNCharColumnWithSparse'

        Invoke-RTRivet -Push 'CreateNCharColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NChar' -TableName 'Foobar' -Sparse
    }

    It 'should create n char column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NChar 'id' 30 -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateNCharColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateNCharColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NChar' -TableName 'Foobar' -NotNull
    }

    It 'should create n char column with custom size collation' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            NChar 'id' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'ShouldCreateNCharColumnWithCustomSizeCollation'

        Invoke-RTRivet -Push 'ShouldCreateNCharColumnWithCustomSizeCollation'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'NChar' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}
