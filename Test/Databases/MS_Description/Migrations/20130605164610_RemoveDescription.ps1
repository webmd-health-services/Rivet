
function Push-Migration()
{
    Remove-Description -TableName MS_Description 
    Remove-Description -TableName MS_Description -ColumnName 'add_description'
}

function Pop-Migration()
{
    Add-Description -Description 'updated description' -TableName MS_Description
    Add-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
}
