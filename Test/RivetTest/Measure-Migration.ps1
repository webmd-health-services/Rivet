
function Measure-Migration
{
    $query = 'select count(*) from {0}.Migrations' -f $RivetSchemaName
    Invoke-RivetTestQuery -Query $query -Connection $DatabaseConnection -AsScalar
}
