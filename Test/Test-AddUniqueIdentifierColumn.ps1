
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

'@ | New-Migration -Name 'CreateUniqueIdentifierColumn'

    Invoke-Rivet -Push 'CreateUniqueIdentifierColumn'
    
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

'@ | New-Migration -Name 'CreateUniqueIdentifierColumnWithSparse'

    Invoke-Rivet -Push 'CreateUniqueIdentifierColumnWithSparse'
    
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

'@ | New-Migration -Name 'CreateUniqueIdentifierColumnWithNotNull'

    Invoke-Rivet -Push 'CreateUniqueIdentifierColumnWithNotNull'
    
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

'@ | New-Migration -Name 'CreateUniqueIdentifierRowGuidCol'

    Invoke-Rivet -Push 'CreateUniqueIdentifierRowGuidCol'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'UniqueIdentifier' -TableName 'Foobar' -NotNull -RowGuidCol
}