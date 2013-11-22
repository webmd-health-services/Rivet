
function Test-Database
{
    param(
    )

    $query = @'
    select count(*) Count from sys.databases where Name = '{0}'
'@ -f $RTDatabaseName

    $count = Invoke-RivetTestQuery -Query $query -Connection $RTMasterConnection -AsScalar
    return ($count -eq 1)
}