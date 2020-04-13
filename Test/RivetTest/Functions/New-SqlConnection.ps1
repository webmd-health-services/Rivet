
function New-SqlConnection
{
    <#
    .SYNOPSIS
    Creates a new database connection.

    .DESCRIPTION
    Don't forget to close it when you're done!
    #>
    param(
        [string]
        # The name of the database.
        $Database = $RTDatabaseName
    )

    Set-StrictMode -Version Latest
    
    $connString = 'Server={0};Database={1};Integrated Security=True;' -f $RTServer,$Database
    $connection = New-Object Data.SqlClient.SqlConnection ($connString)
    $connection.Open()
    return $connection
}

$connection = $null
if( -not $connection -or $connection.State -ne [Data.ConnectionState]::Open )
{
    $connection = New-SqlConnection -Database 'master'
}
