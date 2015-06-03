function Setup
{
    & (Join-Path -Path $PSScriptRoot -ChildPath 'RivetTest\Import-RivetTest.ps1' -Resolve) -DatabaseName 'UpdateStoredProcedure' 
    Start-RivetTest
}

function TearDown
{
    Stop-RivetTest
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
    Remove-StoredProcedure 'TestStoredProcedure'
    Remove-Table 'Person'
}

'@ | New-Migration -Name 'UpdateExistingStoredProcedure'

    Invoke-Rivet -Push 'UpdateExistingStoredProcedure'

    Assert-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT MiddleName, LastName FROM dbo.Person;' -SchemaName 'dbo'
}