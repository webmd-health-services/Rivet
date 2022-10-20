
function Measure-Migration
{
    Set-StrictMode -Version Latest
    
    $query = 'select count(*) from {0}.Migrations where ID >= 00010101000000' -f $RTRivetSchemaName
    Invoke-RivetTestQuery -Query $query -AsScalar
}
