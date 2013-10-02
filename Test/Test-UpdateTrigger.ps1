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
        VarChar 'FirstName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-Trigger -Name 'TestTrigger' -SchemaName 'dbo' -Definition "on dbo.Person after insert, update as raiserror ('Notify Customer Relations', 16, 10);"
    Update-Trigger -Name 'TestTrigger' -SchemaName 'dbo' -Definition "on dbo.Person after update, insert as raiserror ('Notify CEO', 16, 10);"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateTrigger'

    Invoke-Rivet -Push 'UpdateTrigger'

    $triggers = Get-Trigger -TriggerName "TestTrigger"
    Assert-Table 'Person'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "TestTrigger")
    Assert-NotEqual "@{Column0=CREATE trigger [dbo].[TestTrigger] on dbo.Person after insert, update as raiserror ('Notify CEO', 16, 10);}" $triggers
    Assert-Equal "@{Column0=CREATE trigger [dbo].[TestTrigger] on dbo.Person after update, insert as raiserror ('Notify CEO', 16, 10);}" $triggers

}