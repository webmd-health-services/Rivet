
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) 

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateMoneyColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Money 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateMoneyColumn'

    Invoke-RTRivet -Push 'CreateMoneyColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Money' -TableName 'Foobar'
}

function Test-ShouldCreateMoneyColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Money 'id' -Sparse
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateMoneyColumnWithSparse'

    Invoke-RTRivet -Push 'CreateMoneyColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Money' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateMoneyColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        Money 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateMoneyColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateMoneyColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'Money' -TableName 'Foobar' -NotNull
}
