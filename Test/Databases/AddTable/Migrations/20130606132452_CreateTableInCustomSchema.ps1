
function Push-Migration()
{
    Invoke-Query 'create schema psteptest'
    Add-Table 'AddTableInPstepTest' {
        New-Column 'id' -Int -Identity -Description 'AddTableInPstepTest identity column'
    } -SchemaName 'psteptest' -Description 'Testing Add-Table migration for custom schema.' 

    # Sql 2012 feature
    # Add-Table 'FileTable' -FileTable
}

function Pop-Migration()
{
    Invoke-Query 'drop table AddTable'
    Invoke-Query 'drop schema psteptest'
}
