
function Test-Migration
{
    param(
        [Parameter(Mandatory=$true)]
        [UInt64]
        $ID
    )
    
    $migration = Invoke-Query -Query ('select count(*) as Count from migrations.Migrations where ID={0}' -f $ID)
    return ( $migration.Count -gt 0 )
}
