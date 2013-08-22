
function Push-Migration()
{
    Update-Description -Description 'updated description' -TableName MS_Description
    Update-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
}

function Pop-Migration()
{
    Update-Description -Description 'new description' -TableName MS_Description
    Update-Description -Description 'new description' -TableName MS_Description -ColumnName 'add_description'
}
