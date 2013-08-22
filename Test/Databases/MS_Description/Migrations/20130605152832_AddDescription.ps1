
function Push-Migration()
{
    Invoke-Query @'
    create table [MS_Description] (
        add_description varchar(max)
    )
'@

    Add-Description -Description 'new description' -TableName 'MS_Description'
    Add-Description -Description 'new description' -TableName 'MS_Description' -ColumnName 'add_description'
}

function Pop-Migration()
{
    Invoke-Query 'drop table [MS_Description]'
}
