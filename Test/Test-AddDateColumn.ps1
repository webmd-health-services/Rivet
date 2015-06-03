
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) 

function Start-Test
{
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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateDateColumn'

    Invoke-RTRivet -Push 'CreateDateColumn'
    
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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateDateColumnWithSparse'

    Invoke-RTRivet -Push 'CreateDateColumnWithSparse'
    
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
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateDateColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateDateColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Date' -TableName 'Foobar' -NotNull
}
