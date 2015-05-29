
function Push-Migration()
{
    Add-Schema 'rivettest'
    Add-Table 'AddTableInRivetTest' {
        Int 'id' -Identity -Description 'AddTableInRivetTest identity column'
    } -SchemaName 'rivettest' -Description 'Testing Add-Table migration for custom schema.' 

    # Sql 2012 feature
    # Add-Table 'FileTable' -FileTable
}

function Pop-Migration()
{
    Remove-Table 'AddTable'
    Remove-Schema 'rivettest'
}
