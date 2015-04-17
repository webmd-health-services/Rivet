function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddDateColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateDateColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Date 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateColumn'

    Invoke-Rivet -Push 'CreateDateColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Date' -TableName 'Foobar'
}

function Test-ShouldCreateDateColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Date 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateColumnWithSparse'

    Invoke-Rivet -Push 'CreateDateColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Date' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateDateColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Date 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateDateColumnWithNotNull'

    Invoke-Rivet -Push 'CreateDateColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Date' -TableName 'Foobar' -NotNull
}