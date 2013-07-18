
function Stop-RivetTest
{
    $DatabaseConnection.Close()

    Remove-RivetTestDatabase

    Remove-Item -Path $DatabasesRoot -Recurse
}