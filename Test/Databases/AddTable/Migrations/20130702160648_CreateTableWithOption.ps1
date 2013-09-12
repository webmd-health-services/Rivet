
function Push-Migration()
{
    Add-Table 'AddTableWithOption' -Description 'Testing Add-Table migration' -Column {
        VarChar 'varchar' -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        BigInt 'id' -Identity
    } -Option 'data_compression = page'
}

function Pop-Migration()
{
    Remove-Table 'AddTableWithOption'
}
