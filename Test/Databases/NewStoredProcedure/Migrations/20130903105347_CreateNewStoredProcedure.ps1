function Push-Migration()
{
    Add-Table -Name 'Person' -Description 'Testing New-StoredProcedure' -Column {
        New-Column 'FirstName' -VarChar -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        New-Column 'LastName' -VarChar -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    New-StoredProcedure -Name 'TestStoredProcedure' -Definition 'SELECT FirstName, LastName FROM dbo.Person;' -SchemaName 'dbo'
}

function Pop-Migration()
{



}
