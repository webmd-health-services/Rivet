
function Push-Migration()
{
    $updateArgs = @{}
    if( $PSVersionTable.PSVersion = ([Version]'2.0') )
    {
        $updateArgs.ForTable = $true
    }
    Update-Description -Description 'updated description' -TableName MS_Description @updateArgs
    Update-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
}

function Pop-Migration()
{
    Update-Description -Description 'new description' -TableName MS_Description
    Update-Description -Description 'new description' -TableName MS_Description -ColumnName 'add_description'
}
