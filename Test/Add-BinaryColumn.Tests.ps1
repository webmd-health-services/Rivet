
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateBinaryColumn
{
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

function Test-ShouldCreateBinaryColumnWithSparse
{
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

function Test-ShouldCreateBinaryColumnWithNotNull
{
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

function Test-ShouldCreateBinaryColumnWithCustomSize
{
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
