
function Stop-PstepTest
{
    $DatabaseConnection.Close()

    Remove-PstepTestDatabase

    Remove-Item -Path $DatabasesRoot -Recurse
}