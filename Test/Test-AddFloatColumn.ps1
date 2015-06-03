
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateFloatColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Float 'id' 
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateFloatColumn'

    Invoke-RTRivet -Push 'CreateFloatColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar' -Precision 53
}

function Test-ShouldCreateFloatColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Float 'id' 3 -Sparse 
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateFloatColumnWithSparse'

    Invoke-RTRivet -Push 'CreateFloatColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'real' -TableName 'Foobar' -Sparse -Precision 24
}

function Test-ShouldCreateFloatColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Float 'id' 33 -NotNull 
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateFloatColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateFloatColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Float' -TableName 'Foobar' -NotNull -Precision 53
}
