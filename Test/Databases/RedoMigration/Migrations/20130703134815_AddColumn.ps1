
function Push-Migration()
{
    Update-Table -Name 'RedoMigration' -AddColumn {
        Varchar 'description' -Max 
    }

    Add-Table 'SecondTable' {
        Int 'id' -Identity
    }
}

function Pop-Migration()
{
    Remove-Table 'SecondTable' 

    Remove-Column 'description' -TableName 'RedoMigration'
}
