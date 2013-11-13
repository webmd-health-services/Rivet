
function Get-ActivityInfo
{
    param(
        [string]
        # The name of the activity whose info to get.  Otherwise, returns all migrations.
        $Name,

        $Connection = $RTDatabaseConnection
    )
    
    Set-StrictMode -Version Latest

    $query = 'select * from {0}.Activity' -f $RTRivetSchemaName
    if( $Name )
    {
        $query = '{0} where name = ''{1}''' -f $query,$Name
    }
    else
    {
        $query = '{0} order by AtUtc' -f $query
    }


    Invoke-RivetTestQuery -Query $query -Connection $Connection
}