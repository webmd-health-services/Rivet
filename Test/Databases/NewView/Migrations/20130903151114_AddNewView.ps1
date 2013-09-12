function Push-Migration()
{
     Add-Table -Name 'Person' -Description 'Testing New-View' -Column {
        VarChar 'FirstName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        VarChar 'LastName' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    New-ViewOperation -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}

function Pop-Migration()
{
}
