function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddSmallMoneyColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldCreateSmallMoneyColumnNonDataTypeSpecific
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        New-Column 'id' -SmallMoney
    } -Option 'data_compression = none'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'CreateSmallMoneyColumnNonDataTypeSpecific'

    Invoke-Rivet -Push 'CreateSmallMoneyColumnNonDataTypeSpecific'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar'
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