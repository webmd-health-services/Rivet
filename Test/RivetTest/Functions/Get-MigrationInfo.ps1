
function Get-MigrationInfo
{
    param(
        [string]
        # The name of the migration whose info to get.  Otherwise, returns all migrations.
        $Name,

        $Connection,

        $DatabaseName,

        [switch] $Force
    )

    Set-StrictMode -Version Latest

    $whereClause = " where ID >= $($script:firstMigrationId)"
    if ($Force)
    {
        $whereClause = ''
    }

    # Exclude Rivet's internal migrations.
    $query = "select * from $($RTRivetSchemaName).Migrations${whereClause}"
    if( $Name )
    {
        $query = '{0} and  name = ''{1}''' -f $query,$Name
    }
    else
    {
        $query = '{0} order by AtUtc' -f $query
    }

    $optionalParam = @{ }
    if( $Connection )
    {
        $optionalParam['Connection'] = $Connection
    }

    if( $DatabaseName )
    {
        $optionalParam['DatabaseName'] = $DatabaseName
    }

    Invoke-RivetTestQuery -Query $query @optionalParam
}
