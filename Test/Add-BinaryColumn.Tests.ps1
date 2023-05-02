
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-BinaryColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create binary column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Binary 'id'  500
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateBinaryColumn'

        Invoke-RTRivet -Push 'CreateBinaryColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar' -Size 500
    }

    It 'should create binary column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Binary 'id' 500 -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateBinaryColumnWithSparse'

        Invoke-RTRivet -Push 'CreateBinaryColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar' -Sparse -Size 500
    }

    It 'should create binary column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Binary 'id' 500 -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateBinaryColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateBinaryColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar' -NotNull -Size 500
    }

    It 'should create binary column with custom size' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            Binary 'id' -NotNull -Size 50
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'ShouldCreateBinaryColumnWithCustomSizeCollation'

        Invoke-RTRivet -Push 'ShouldCreateBinaryColumnWithCustomSizeCollation'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'Binary' -TableName 'Foobar' -NotNull -Size 50
    }
}
