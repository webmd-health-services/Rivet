
function Get-ActivityInfo
{
    param(
        [string]
        # The name of the activity whose info to get.  Otherwise, returns all migrations.
        $Name,

        $Connection
    )
    
    Set-StrictMode -Version Latest

    $query = "select * from $($RTRivetSchemaName).Activity where MigrationID >= $($script:firstMigrationId)"
    if( $Name )
    {
        $query = '{0} and name = ''{1}''' -f $query,$Name
    }
    else
    {
        $query = '{0} order by AtUtc' -f $query
    }

    $connParam = @{ }
    if( $Connection )
    {
        $connParam['Connection'] = $Connection
    }
    Invoke-RivetTestQuery -Query $query @connParam
}
