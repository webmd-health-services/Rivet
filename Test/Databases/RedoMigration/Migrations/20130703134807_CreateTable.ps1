
function Push-Migration()
{
    Add-Table 'RedoMigration' {
        Int 'id' -Identity
    }
}

function Pop-Migration()
{
    Remove-Table 'RedoMigration'
}
