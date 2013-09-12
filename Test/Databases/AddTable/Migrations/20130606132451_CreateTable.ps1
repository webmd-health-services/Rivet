
function Push-Migration()
{
    Add-Table -Name 'AddTable' -Description 'Testing Add-Table migration' -Column {
        VarChar 'varchar' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        BigInt 'id' -Identity
    } -Option 'data_compression = none'

    # Sql 2012 feature
    # Add-Table 'FileTable' -FileTable
}

function Pop-Migration()
{
    Invoke-Query 'drop table AddTable'
}
