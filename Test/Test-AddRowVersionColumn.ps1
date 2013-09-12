function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddRowVersionColumn' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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
    
}

'@ | New-Migration -Name 'CreateRowVersionColumnWithNotNull'

    Invoke-Rivet -Push 'CreateRowVersionColumnWithNotNull'
    
    Assert-Table 'Foobar'
    Assert-Column -Name 'id' -DataType 'timestamp' -TableName 'Foobar' -NotNull
}