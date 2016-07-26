
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateUniqueIdentifierColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        UniqueIdentifier 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateUniqueIdentifierColumn'

    Invoke-RTRivet -Push 'CreateUniqueIdentifierColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar'
}

function Test-ShouldCreateUniqueIdentifierColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        UniqueIdentifier 'id' -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateUniqueIdentifierColumnWithSparse'

    Invoke-RTRivet -Push 'CreateUniqueIdentifierColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateUniqueIdentifierColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        UniqueIdentifier 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateUniqueIdentifierColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateUniqueIdentifierColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar' -NotNull
}

function Test-ShouldCreateUniqueIdentifierRowGuidCol
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        UniqueIdentifier 'id' -NotNull -RowGuidCol
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateUniqueIdentifierRowGuidCol'

    Invoke-RTRivet -Push 'CreateUniqueIdentifierRowGuidCol'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar' -NotNull -RowGuidCol
}
