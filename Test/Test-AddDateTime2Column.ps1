function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddDateTime2Column' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateDateTime2Column
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTime2Column'

    Invoke-Rivet -Push 'CreateDateTime2Column'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -Scale 7
}

function Test-ShouldCreateDateTime2ColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id' 6 -Sparse 
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTime2ColumnWithSparse'

    Invoke-Rivet -Push 'CreateDateTime2ColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -Sparse -Scale 6
}

function Test-ShouldCreateDateTime2ColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        DateTime2 'id' 6 -NotNull  
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateTime2ColumnWithNotNull'

    Invoke-Rivet -Push 'CreateDateTime2ColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'DateTime2' -TableName 'Foobar' -NotNull -Scale 6
}