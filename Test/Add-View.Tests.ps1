
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Setup
{
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
}

function Test-ShouldAddView
{
    @'
function Push-Migration
{
     Add-Table -Name 'Person' -Description 'Testing Add-View' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}

function Pop-Migration()
{
    Remove-View 'customView'
    Remove-Table 'Person'
}
'@ | New-TestMigration -Name 'AddNewView'
    Invoke-RTRivet -Push 'AddNewView'
    
    Assert-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}
