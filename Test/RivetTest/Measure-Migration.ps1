
function Measure-Migration
{
    $query = 'select count(*) from pstep.Migrations'
    Invoke-PstepTEstQuery -Query $query -Connection $DatabaseConnection -AsScalar
}
