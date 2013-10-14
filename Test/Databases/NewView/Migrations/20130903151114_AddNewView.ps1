function Push-Migration
{
     Add-Table -Name 'Person' -Description 'Testing Add-View' -Column {
        VarChar 'FirstName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -Max -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    Add-View -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}

function Pop-Migration()
{
}
