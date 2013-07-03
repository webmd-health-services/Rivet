
function Push-Migration()
{
    Add-Table 'AddTable' -Description 'Testing Add-Table migration' -Column {
        New-Column 'varchar' -VarChar -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        New-Column 'id' -BigInt -Identity
    } -Option 'data_compression = none'

    # Sql 2012 feature
    # Add-Table 'FileTable' -FileTable
}

function Pop-Migration()
{
    Invoke-Query 'drop table AddTable'
}
