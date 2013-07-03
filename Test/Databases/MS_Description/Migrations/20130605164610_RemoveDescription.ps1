
function Push-Migration()
{
    $removeArgs = @{ }
    if( $PSVersionTable.PSVersion -eq ([Version]'2.0') )
    {
        $removeArgs.ForTable = $true
    }
    Remove-Description -TableName MS_Description @removeArgs
    Remove-Description -TableName MS_Description -ColumnName 'add_description'
}

function Pop-Migration()
{
    Add-Description -Description 'updated description' -TableName MS_Description
    Add-Description -Description 'updated description' -TableName MS_Description -ColumnName 'add_description'
}
