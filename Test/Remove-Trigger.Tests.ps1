
& (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve)

function Start-Test
{
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
}

function Test-ShouldRemoveTrigger
{
    @'
function Push-Migration
{
    Add-Table -Name 'Person' -Description 'Testing Add-StoredProcedure' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-Trigger -Name 'TestTrigger' -SchemaName 'dbo' -Definition "on dbo.Person after insert, update as raiserror ('Notify Customer Relations', 16, 10);"
    Remove-Trigger -Name 'TestTrigger' -SchemaName 'dbo'
}

function Pop-Migration
{
    Remove-Table 'Person'
}

'@ | New-TestMigration -Name 'RemoveTrigger'

    Invoke-RTRivet -Push 'RemoveTrigger'

    Assert-Table 'Person'
    Assert-False (Test-DatabaseObject -SQLTrigger -Name "TestTrigger")

}
