
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
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
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateSmallMoneyColumn'

    Invoke-RTRivet -Push 'CreateSmallMoneyColumn'
    
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
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateSmallMoneyColumnWithSparse'

    Invoke-RTRivet -Push 'CreateSmallMoneyColumnWithSparse'
    
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
    Remove-Table 'Foobar'
}

'@ | New-TestMigration -Name 'CreateSmallMoneyColumnWithNotNull'

    Invoke-RTRivet -Push 'CreateSmallMoneyColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'SmallMoney' -TableName 'Foobar' -NotNull
}
