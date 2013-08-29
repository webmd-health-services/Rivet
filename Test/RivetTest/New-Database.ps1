
function New-Database
{
    param(
        [string]
        # The name of the database.
        $Name = $RTDatabaseName
    )

    Set-StrictMode -Version Latest
    
    $query = @'
    if( not exists( select name from sys.databases where Name = '{0}' ) )
    begin
        create database [{0}]
    end
'@ -f $Name

    Invoke-RivetTestQuery -Query $query -Master

}