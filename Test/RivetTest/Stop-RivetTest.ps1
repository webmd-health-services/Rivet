
function Stop-RivetTest
{
    $RTDatabaseConnection.Close()

    Remove-RivetTestDatabase

    Remove-Item -Path $RTDatabasesRoot -Recurse
}