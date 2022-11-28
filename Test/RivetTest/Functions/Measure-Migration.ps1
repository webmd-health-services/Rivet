
function Measure-Migration
{
    Set-StrictMode -Version Latest
    
    $query = "select count(*) from $($RTRivetSchemaName).Migrations where ID >= $($script:firstMigrationId)"
    Invoke-RivetTestQuery -Query $query -AsScalar
}
