
function Push-Migration()
{
    Invoke-Query @'
    create table [MS_Description] (
        add_description varchar(max)
    )
'@
    $tableParams = @{ }
    if( $PSVersionTable.PSVersion -eq ([Version]'2.0') )
    {
        $tableParams.ForTable = $true
    }
    Add-Description -Description 'new description' -TableName MS_Description @tableParams
    Add-Description -Description 'new description' -TableName MS_Description -ColumnName 'add_description'
}

function Pop-Migration()
{
    Invoke-Query 'drop table [MS_Description]'
}
