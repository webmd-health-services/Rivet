
function Stop-RivetTest
{
    Set-StrictMode -Version 'Latest'

    if( $RTDatabaseName )
    {
        Clear-TestDatabase -Name $RTDatabaseName
    }

    if( $RTDatabasesRoot -and (Test-Path -Path $RTDatabasesRoot) )
    {
        Remove-Item -Path $RTDatabasesRoot -Recurse
    }
}
