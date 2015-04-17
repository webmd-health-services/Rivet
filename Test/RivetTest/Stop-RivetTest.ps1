
function Stop-RivetTest
{
    $Script:RTDatabaseConnection.Close()

    Remove-RivetTestDatabase

    Remove-Item -Path $RTDatabasesRoot -Recurse
}