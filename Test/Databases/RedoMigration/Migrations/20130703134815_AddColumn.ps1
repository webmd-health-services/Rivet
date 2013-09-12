
function Push-Migration()
{
    Add-Column 'description' -VarChar -TableName 'RedoMigration'

    Add-Table 'SecondTable' {
        Int 'id' -Identity
    }
}

function Pop-Migration()
{
    Remove-Table 'SecondTable' 

    Remove-Column 'description' -TableName 'RedoMigration'
}
