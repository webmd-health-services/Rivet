
function Test-Database
{
    param(
    )

    $query = @'
    select count(*) Count from sys.databases where Name = '{0}'
'@ -f $DatabaseName

    $count = Invoke-RivetTestQuery -Query $query -Connection $MasterConnection -AsScalar
    return ($count -eq 1)
}