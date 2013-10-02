function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'UpdateView' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldUpdateView
{
    @'
function Push-Migration
{
         Add-Table -Name 'Person' -Description 'Testing Add-View' -Column {
        VarChar 'FirstName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
    Update-View -Name "customView" -Schema "dbo" -Definition "as select LastName from Person"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateView'

    Invoke-Rivet -Push 'UpdateView'
    
    Assert-View -Name "customView" -Schema "dbo" -Definition "as select LastName from Person"
}