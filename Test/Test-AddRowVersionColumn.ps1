
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldCreateRowVersionColumn
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        RowVersion 'id'
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateRowVersionColumn'

    Invoke-Rivet -Push 'CreateRowVersionColumn'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'timestamp' -TableName 'Foobar' -NotNull
}


function Test-ShouldCreateRowVersionColumnWithNotNull
{
    @'
function Push-Migration
{
    Add-Table -Name 'Foobar' -Column {
        RowVersion 'id' -NotNull
    }
}

function Pop-Migration
{
    Remove-Table 'Foobar'
}

'@ | New-Migration -Name 'CreateRowVersionColumnWithNotNull'

    Invoke-Rivet -Push 'CreateRowVersionColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'timestamp' -TableName 'Foobar' -NotNull
}