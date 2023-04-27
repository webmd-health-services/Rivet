
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateSqlVariantColumn
{
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

function Test-ShouldCreateSqlVariantColumnWithSparse
{
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

function Test-ShouldCreateSqlVariantColumnWithNotNull
{
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
