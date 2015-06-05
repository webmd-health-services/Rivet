
function Stop-RivetTest
{

    Set-StrictMode -Version 'Latest'

    Clear-TestDatabase -Name $RTDatabaseName

    Remove-Item -Path $RTDatabasesRoot -Recurse
}
