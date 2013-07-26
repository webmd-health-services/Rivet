
function Measure-Migration
{
    Set-StrictMode -Version Latest
    
    $query = 'select count(*) from {0}.Migrations' -f $RTRivetSchemaName
    Invoke-RivetTestQuery -Query $query -Connection $RTDatabaseConnection -AsScalar
}
