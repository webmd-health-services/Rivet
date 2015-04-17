function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'UpdateTrigger' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldUpdateTrigger
{
    @'
function Push-Migration
{
    Add-Table -Name 'Person' -Description 'Testing Update-StoredProcedure' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-Trigger -Name 'TestTrigger' -Definition "on dbo.Person after insert, update as raiserror ('Notify Customer Relations', 16, 10);"
    Update-Trigger -Name 'TestTrigger' -Definition "on dbo.Person after update, insert as raiserror ('Notify CEO', 16, 10);"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateTrigger'

    Invoke-Rivet -Push 'UpdateTrigger'

    Assert-Trigger -Name 'TestTrigger' -Definition "on dbo.Person after update, insert as raiserror ('Notify CEO', 16, 10);"
}

function Test-ShouldUpdateTriggerInCustomSchema
{
    @'
function Push-Migration
{
    Add-Schema 'fizz'
    Add-Table -Name 'Person' -Description 'Testing Update-StoredProcedure' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none' -Schema 'fizz'

    Add-Trigger -Name 'TestTrigger' -Schema 'fizz' -Definition "on fizz.Person after insert, update as raiserror ('Notify Customer Relations', 16, 10);"
    Update-Trigger -Name 'TestTrigger' -Schema 'fizz' -Definition "on fizz.Person after update, insert as raiserror ('Notify CEO', 16, 10);"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateTriggerinCustomSchema'

    Invoke-Rivet -Push 'UpdateTriggerinCustomSchema'

    Assert-Trigger -Name 'TestTrigger' -SchemaName 'fizz' -Definition "on fizz.Person after update, insert as raiserror ('Notify CEO', 16, 10);"
}