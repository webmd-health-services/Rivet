
function Push-Migration()
{
    Add-Table 'RedoMigration' {
        New-Column 'id' -Int -Identity
    }
}

function Pop-Migration()
{
    Remove-Table 'RedoMigration'
}
