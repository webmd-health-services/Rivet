function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddRealColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateRealColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Real 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateRealColumn'

    Invoke-Rivet -Push 'CreateRealColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar'
}

function Test-ShouldCreateRealColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Real 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateRealColumnWithSparse'

    Invoke-Rivet -Push 'CreateRealColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateRealColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Real 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateRealColumnWithNotNull'

    Invoke-Rivet -Push 'CreateRealColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Real' -TableName 'Foobar' -NotNull
}