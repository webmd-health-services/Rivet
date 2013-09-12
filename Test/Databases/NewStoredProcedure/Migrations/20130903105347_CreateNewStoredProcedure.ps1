function Push-Migration()
{
    Add-Table -Name 'Person' -Description 'Testing New-StoredProcedure' -Column {
        VarChar 'FirstName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    New-StoredProcedure -Name 'TestStoredProcedure' -Definition 'as SELECT FirstName, LastName FROM dbo.Person;' -SchemaName 'dbo'
}

function Pop-Migration()
{



}
