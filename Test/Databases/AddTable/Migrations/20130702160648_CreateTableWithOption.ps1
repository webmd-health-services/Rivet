
function Push-Migration()
{
    Add-Table 'AddTableWithOption' -Description 'Testing Add-Table migration' -Column {
        New-Column 'varchar' -VarChar -NotNull -Default "'default'" -Description 'varchar(max) constraint DF_AddTable_varchar default default'
        New-Column 'id' -BigInt -Identity
    } -Option 'data_compression = page'
}

function Pop-Migration()
{
    Remove-Table 'AddTableWithOption'
}
