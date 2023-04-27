
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)
}

Describe 'Add-SqlVariantColumn' {
    BeforeEach {
        Start-RivetTest
    }

    AfterEach {
        Stop-RivetTest
    }

    It 'should create sql variant column' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SqlVariant 'id'
        } -Option 'data_compression = none'
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSqlVariantColumn'

        Invoke-RTRivet -Push 'CreateSqlVariantColumn'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'sql_variant' -TableName 'Foobar'
    }

    It 'should create sql variant column with sparse' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SqlVariant 'id' -Sparse
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSqlVariantColumnWithSparse'

        Invoke-RTRivet -Push 'CreateSqlVariantColumnWithSparse'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'sql_variant' -TableName 'Foobar' -Sparse
    }

    It 'should create sql variant column with not null' {
        @'
    function Push-Migration
    {
        Add-Table -Name 'Foobar' -Column {
            SqlVariant 'id' -NotNull
        }
    }

    function Pop-Migration
    {
        Remove-Table 'Foobar'
    }

'@ | New-TestMigration -Name 'CreateSqlVariantColumnWithNotNull'

        Invoke-RTRivet -Push 'CreateSqlVariantColumnWithNotNull'

        Assert-Table 'Foobar'
        Assert-Column -Name 'id' -DataType 'sql_variant' -TableName 'Foobar' -NotNull
    }
}
