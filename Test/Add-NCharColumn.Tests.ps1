
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateNCharColumn
{
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

function Test-ShouldCreateNCharColumnWithSparse
{
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

function Test-ShouldCreateNCharColumnWithNotNull
{
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

function Test-ShouldCreateNCharColumnWithCustomSizeCollation
{
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
