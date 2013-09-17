function Start-Test
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'AddTrigger' 
    Start-RivetTest
}

function Stop-Test
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldAddTrigger
{
    @'
function Push-Migration
{
    Add-Table -Name 'Person' -Description 'Testing Add-StoredProcedure' -Column {
        VarChar 'FirstName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-Trigger -Name 'TestTrigger' -SchemaName 'dbo' -Definition "on dbo.Person after insert, update as raiserror ('Notify Customer Relations', 16, 10);"
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'AddTrigger'

    Invoke-Rivet -Push 'AddTrigger'

    Assert-Table 'Person'
    Assert-True (Test-DatabaseObject -SQLTrigger -Name "TestTrigger")

}