
function Get-MigrationInfo
{
    param(
        [string]
        # The name of the migration whose info to get.  Otherwise, returns all migrations.
        $Name,

        $Connection = $DatabaseConnection
    )

    $query = 'select * from pstep.Migrations'
    if( $Name )
    {
        $query = '{0} where name = ''{1}''' -f $query,$Name
    }
    else
    {
        $query = '{0} order by AtUtc' -f $query
    }


    Invoke-PstepTestQuery -Query $query -Connection $Connection
}