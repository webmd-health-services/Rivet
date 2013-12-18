function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'UpdateTrigger' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
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

    $triggers = Get-Trigger -Name "TestTrigger"
    Assert-Table 'Person'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "TestTrigger")
    Assert-NotEqual "@{Column0=CREATE trigger [dbo].[TestTrigger] on dbo.Person after insert, update as raiserror ('Notify CEO', 16, 10);}" $triggers
    Assert-Equal "@{Column0=CREATE trigger [dbo].[TestTrigger] on dbo.Person after update, insert as raiserror ('Notify CEO', 16, 10);}" $triggers

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

    $triggers = Get-Trigger -Name "TestTrigger"
    Assert-Table 'Person' -Schema 'fizz'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "TestTrigger" -Schema 'fizz')
    Assert-NotEqual "@{Column0=CREATE trigger [fizz].[TestTrigger] on fizz.Person after insert, update as raiserror ('Notify CEO', 16, 10);}" $triggers
    Assert-Equal "@{Column0=CREATE trigger [fizz].[TestTrigger] on fizz.Person after update, insert as raiserror ('Notify CEO', 16, 10);}" $triggers

}