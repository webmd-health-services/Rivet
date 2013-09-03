function Push-Migration()
{
     Add-Table -Name 'Person' -Description 'Testing New-View' -Column {
        New-Column 'FirstName' -VarChar -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        New-Column 'LastName' -VarChar -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
    } -Option 'data_compression = none'

    New-ViewOperation -Name "customView" -Schema "dbo" -Definition "as select FirstName from Person"
}

function Pop-Migration()
{
}
