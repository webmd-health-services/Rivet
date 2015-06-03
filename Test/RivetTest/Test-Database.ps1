
function Test-Database
{
    param(
        [string]
        # The name of the database.
        $Name = $RTDatabaseName
    )

    $query = @'
    select count(*) Count from sys.databases where Name = '{0}'
'@ -f $Name

    $count = Invoke-RivetTestQuery -Query $query -Master -AsScalar
    return ($count -eq 1)
}