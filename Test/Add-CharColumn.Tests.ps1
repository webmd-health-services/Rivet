
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-CharColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create char column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Char 'id' 10
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateCharColumn'

        Invoke-RTRivet -Push 'CreateCharColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -Size 10
    }

    It 'should create char column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Char 'id' 10 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateCharColumnWithSparse'

        Invoke-RTRivet -Push 'CreateCharColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -Sparse -Size 10
    }

    It 'should create char column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Char 'id' 10 -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateCharColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateCharColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -NotNull -Size 10
    }

    It 'should create char column with custom size collation' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Char 'id' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'ShouldCreateCharColumnWithCustomSizeCollation'

        Invoke-RTRivet -Push 'ShouldCreateCharColumnWithCustomSizeCollation'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Char' -TableName 'Foobar' -NotNull -Size 50 -Collation "Chinese_Taiwan_Stroke_CI_AS"
    }
}
