function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'RemoveDataType' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldRemoveDataTypeByTable
{
    @'
function Push-Migration
{
    Add-DataType 'Users' -AsTable { varchar 'Name' 50 } -TableConstraint 'primary key'
    Remove-DataType 'Users'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'ByTable'

    Invoke-Rivet -Push 'ByTable'

    $temp = Invoke-RivetTestQuery -Query 'select * from sys.table_types'
    Assert-Null $temp
}