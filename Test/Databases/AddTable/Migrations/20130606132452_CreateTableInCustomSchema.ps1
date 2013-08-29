
function Push-Migration()
{
    Invoke-Query 'create schema rivettest'
    Add-Table 'AddTableInRivetTest' {
        New-Column 'id' -Int -Identity -Description 'AddTableInRivetTest identity column'
    } -SchemaName 'rivettest' -Description 'Testing Add-Table migration for custom schema.' 

    # Sql 2012 feature
    # Add-Table 'FileTable' -FileTable
}

function Pop-Migration()
{
    Invoke-Query 'drop table AddTable'
    Invoke-Query 'drop schema rivettest'
}
