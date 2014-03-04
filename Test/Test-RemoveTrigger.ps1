function Start-Test
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'RemoveTrigger' 
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
    
}

'@ | New-Migration -Name 'RemoveTrigger'

    Invoke-Rivet -Push 'RemoveTrigger'

    Assert-Table 'Person'
    Assert-False (Test-DatabaseObject -SQLTrigger -Name "TestTrigger")

}