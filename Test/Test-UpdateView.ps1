
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldUpdateView
{
    @'
function Push-Migration
{
    Add-Table -Name 'Person' -Description 'Testing Add-View' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
    Update-View -Name "customView" -Schema "dbo" -Definition "as select LastName from Person"
}

function Pop-Migration
{
    Remove-View 'customView'
    Remove-Table 'Person'
}

'@ | New-Migration -Name 'UpdateView'

    Invoke-Rivet -Push 'UpdateView'
    
    Assert-View -Name "customView" -Schema "dbo" -Definition "as select LastName from Person"
}