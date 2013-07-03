
function Get-MigrationInfo
{
    param(
        [string]
        # The name of the migration whose info to get.  Otherwise, returns all migrations.
        $Name
    )

    $query = 'select * from pstep.Migrations'
    if( $Name )
    {
        $query = $query + (' where name = ''{0}''' -f $Name)
    }

    Invoke-PstepTestQuery -Query $query -Connection $DatabaseConnection
}