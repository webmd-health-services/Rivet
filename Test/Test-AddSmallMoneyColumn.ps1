function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'AddSmallMoneyColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateSmallMoneyColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallMoney 'id'
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateSmallMoneyColumn'

    Invoke-Rivet -Push 'CreateSmallMoneyColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar'
}

function Test-ShouldCreateSmallMoneyColumnWithSparse
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallMoney 'id' -Sparse
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateSmallMoneyColumnWithSparse'

    Invoke-Rivet -Push 'CreateSmallMoneyColumnWithSparse'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar' -Sparse
}

function Test-ShouldCreateSmallMoneyColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        SmallMoney 'id' -NotNull
    }
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateSmallMoneyColumnWithNotNull'

    Invoke-Rivet -Push 'CreateSmallMoneyColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar' -NotNull
}