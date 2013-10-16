function Setup
{
    Import-Module -Name (Join-Path $TestDir 'RivetTest') -ArgumentList 'UpdateStoredProcedure' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
    Remove-Module RivetTest
}

function Test-ShouldUpdateExistingStoredProcedure
{
    @'
function Push-Migration
{
    Add-Table -Name 'Person' -Description 'Testing Add-StoredProcedure' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'MiddleName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT FirstName, LastName FROM dbo.Person;' -SchemaName 'dbo'
    Update-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT MiddleName, LastName FROM dbo.Person;' -SchemaName 'dbo'
}

function Pop-Migration
{
    
}

'@ | New-Migration -Name 'UpdateExistingStoredProcedure'

    Invoke-Rivet -Push 'UpdateExistingStoredProcedure'

    Assert-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT MiddleName, LastName FROM dbo.Person;' -SchemaName 'dbo'
}