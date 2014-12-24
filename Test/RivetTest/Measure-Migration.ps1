
function Measure-Migration
{
    Set-StrictMode -Version Latest
    
    $query = 'select count(*) from {0}.Migrations where ID >= 01000000000000' -f $RTRivetSchemaName
    Invoke-RivetTestQuery -Query $query -Connection $RTDatabaseConnection -AsScalar
}
